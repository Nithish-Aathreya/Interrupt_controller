`include "intr_cntrlr.v"
//TB is responsible for 3 things:
//1. Acting as processor to serve interrupts based on priority
//2. Acting as processor in configuring priority register
//3. Acting as peripheral controllers for raising interrupts
module tb;

parameter NUM_P_CTRLR=16; 
parameter ADDR_REG=$clog2(NUM_P_CTRLR); //4
parameter PRIO_RANGE=$clog2(NUM_P_CTRLR); //4

//APB signals
reg[200:1]testname;
reg pclk,prst,pwrite,penable;
reg [ADDR_REG-1:0]paddr;
reg [PRIO_RANGE-1:0]pwdata;
wire[PRIO_RANGE-1:0]prdata;
wire pready,perror;

//signals from interrupt controller
wire intr_valid_o;
reg intr_serviced_i;
wire [NUM_P_CTRLR-1:0]intr_to_service_o;
reg [NUM_P_CTRLR-1:0]intr_active_i;

integer i,j,seed=888;
reg [PRIO_RANGE-1:0] random_array[NUM_P_CTRLR-1:0];
integer unique_value,k,l,exists,h;

//initializing design as DUT here,with parameter overriding
ctlr#(.NUM_P_CTRLR(NUM_P_CTRLR),.ADDR_REG(ADDR_REG),.PRIO_RANGE(PRIO_RANGE)) dut(pclk,prst,paddr,pwrite,pwdata,prdata,penable,pready,perror,intr_valid_o,intr_serviced_i,intr_to_service_o,intr_active_i);

initial //clk generation
begin
    pclk=0;
    forever #5 pclk=~pclk;
end

initial
begin
$value$plusargs("testname=%s",testname);
    reset();
case(testname)

    "low_index_low_prio": begin //index[0]:0,index[1]:1...index[15]:15
    write_1();
    read_1();
    end

    //index[0]:15,index[1]:14...index[15]:0
    "low_index_high_prio": begin
                            write_2();
                            read_2();
                            end
    
        "unique_priority": begin            //-unique priority values will be assigned to peripheral controllers
                            write_3();      //- peripheral controllers which has highest priority will be served first   
                            read_3();
                            end
            endcase

intr_active_i = $random(seed); //mimics the peripheral controller hand raising 
    #500;
$finish;
end

//mimics the processor serving interrupts
always@(posedge intr_valid_o) begin
#50;
intr_active_i[intr_to_service_o] =0;//forces to lower the raised interrupt
#5;
intr_serviced_i=1;//Generating signal, which indicates it has successfully served the interrupt

@(posedge pclk);
intr_serviced_i=0;//reseting the signal,so that for next interrupt cycle continues


end

task reset();
    begin
        prst=1;
    penable=0;
    pwrite=0;
    paddr=0;
    pwdata=0;
    intr_serviced_i=0;
    intr_active_i=0;
    exists=0;
    @(posedge pclk);
    prst=0;
    end
endtask

task write_1();
    begin
    for(i=0;i<NUM_P_CTRLR  ;i=i+1)

    begin
        @(posedge pclk);
        paddr=i;
        penable=1;
        pwrite=1;
        pwdata= i;
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
        pwdata=0;
    end
endtask

task read_1();
    begin
    for(j=0;j<NUM_P_CTRLR;j=j+1)
    begin
        @(posedge pclk);
        paddr=j;
        penable=1;
        pwrite=0;
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
    end
endtask

task write_2();
    begin
    for(i=0;i<NUM_P_CTRLR  ;i=i+1)

    begin
        @(posedge pclk);
        paddr=i;
        penable=1;
        pwrite=1;
        pwdata= NUM_P_CTRLR-1-i;
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
        pwdata=0;
    end
endtask

task read_2();
    begin
    for(j=0;j<NUM_P_CTRLR;j=j+1)
    begin
        @(posedge pclk);
        paddr=j;
        penable=1;
        pwrite=0;
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
    end
endtask

  task write_3();
  begin

      
      for(k=0;k<NUM_P_CTRLR;) begin //generating unique random value
        unique_value=$urandom_range(0,2**PRIO_RANGE-1);
        exists=0;
        
        for(l=0;l<k;l=l+1) begin
          if(unique_value==random_array[l]) begin
      exists=1;
      l=k;
    end
  end
        
    if(exists==0) begin
      random_array[k]=unique_value;
    k=k+1;
    end
  end
      for (h = 0; h < NUM_P_CTRLR; h = h + 1) begin
        $display("random_array[%0d]=%0h", h, random_array[h]);
    end

        
  
     for(i=0;i<NUM_P_CTRLR  ;i=i+1) //NUM_P_CTRLR=16

    begin
        @(posedge pclk);
        paddr=i;
        penable=1;
        pwrite=1;
      pwdata= random_array[i]; //assigning unique value
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
        pwdata=0;
    end
endtask


task read_3();
    begin
    for(j=0;j<NUM_P_CTRLR;j=j+1)
    begin
        @(posedge pclk);
        paddr=j;
        penable=1;
        pwrite=0;
        wait(pready==1);
    end

        @(posedge pclk);
        paddr=0;
        penable=0;
        pwrite=0;
    end
endtask
endmodule


