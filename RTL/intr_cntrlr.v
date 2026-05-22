module ctlr(pclk,prst,paddr,pwrite,pwdata,prdata,penable,pready,perror,intr_valid_o,intr_serviced_i,intr_to_service_o,intr_active_i);

parameter NUM_P_CTRLR=16; 
parameter ADDR_REG=$clog2(NUM_P_CTRLR); 
parameter PRIO_RANGE=$clog2(NUM_P_CTRLR); 
//parameter PER_INDEX=$clog2(NUM_P_CTRLR); 
parameter s_a=3'b001; 
parameter s_b=3'b010; 
parameter s_c=3'b100; 

reg[2:0]state,nxt_state;
integer i;

input pclk,prst,pwrite,penable;
input [ADDR_REG-1:0]paddr;
input [PRIO_RANGE-1:0]pwdata;
output reg[PRIO_RANGE-1:0]prdata;
output reg pready,perror;
output reg intr_valid_o;
input intr_serviced_i;
output reg[NUM_P_CTRLR-1:0]intr_to_service_o;
input [NUM_P_CTRLR-1:0]intr_active_i;

reg first_per_f;
reg[NUM_P_CTRLR-1:0]current_high_prio;
reg [NUM_P_CTRLR-1:0]intr_with_high_prio;


reg [PRIO_RANGE-1:0]priority_reg[NUM_P_CTRLR-1:0];

//process 1-->to write into priority reg
always@(posedge pclk)
begin
    if(prst) begin
        prdata=0;
        pready=0;
        perror=0;
        intr_valid_o=0;
        intr_to_service_o=0;
        first_per_f=0;
        current_high_prio=0;
        intr_with_high_prio=0;
        state=s_a;
        nxt_state=s_a;

        for(i=0;i<NUM_P_CTRLR;i=i+1)
            priority_reg[i]=0;
    end
else
begin
if(penable)
    begin
        pready=1;
        if(pwrite)
            priority_reg[paddr]<=pwdata;

        else  //pwrite=0
                prdata<=priority_reg[paddr];
        end
    else //penable=0
        pready=0;

end  //rst=0

end   //always block

//process 2 -->handling interrupts

always@(posedge pclk) begin
    if(prst==0) begin
case(state)
    s_a: begin //idle waiting for interrupt to arrive
        if(intr_active_i!=0) begin 
               nxt_state<=s_b;
                first_per_f=1;
           end
               else
               nxt_state<=s_a;
    end
    s_b: begin//find out which has highest priority
        for(i=0;i<NUM_P_CTRLR;i=i+1) begin
            if(intr_active_i[i]) begin
                if(first_per_f) begin 
                    first_per_f=0;
                    current_high_prio=priority_reg[i];
                    intr_with_high_prio=i;

                end
                else begin
                 if(current_high_prio<priority_reg[i]
                     ) begin   
                    current_high_prio=priority_reg[i];
                    intr_with_high_prio=i;
                end
                end

            end //if

        end //for
          intr_to_service_o=intr_with_high_prio;
          intr_valid_o=1;
          nxt_state<=s_c; 
    end //state

    s_c: begin //waiting to interrup to get serviced
    if(intr_serviced_i==1) begin
        first_per_f=1;
        intr_to_service_o=0;
        intr_valid_o=0;
        current_high_prio=0;

        if(intr_active_i !=0)   begin 
        first_per_f=1;
        nxt_state<=s_b;
        end
        
        else
            nxt_state<=s_a;
end
end
endcase

end
end   //always block

always@(nxt_state)
    state=nxt_state;

endmodule
