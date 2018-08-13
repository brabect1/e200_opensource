module spi_model(
    input  logic sck,
    input  logic rst_n,
    input  logic cs_n,
    input  logic[3:0] dq_i,
    output logic[3:0] dq_o,
    output logic[3:0] dq_t
);

logic [7:0] buffer_in;
logic [7:0] buffer_out;
int cnt;

always_ff @(posedge sck or negedge rst_n or posedge cs_n) begin
    if (!rst_n | cs_n)
        cnt <= 0;
    else
        cnt <= cnt + 1;
end

always_ff @(posedge sck or negedge rst_n) begin
    if (!rst_n)
        buffer_in <= 'x;
    else if (!cs_n)
        buffer_in <= {buffer_in[6:0],dq_i[0]};
end

assign dq_o = {2'b00,buffer_out[7],1'b0};
assign dq_t = 4'b1101;

always_ff @(negedge sck or negedge rst_n) begin
    if (!rst_n)
        buffer_out <= '0;
    else if (!cs_n)
        if ((cnt & 3'd7) == 0)
            buffer_out <= buffer_in;
        else
            buffer_out <= {buffer_out[6:0],1'b0};
end

endmodule: spi_model
