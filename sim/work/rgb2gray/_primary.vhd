library verilog;
use verilog.vl_types.all;
entity rgb2gray is
    port(
        clk             : in     vl_logic;
        rstb            : in     vl_logic;
        i_hav           : in     vl_logic;
        i_vav           : in     vl_logic;
        i_r             : in     vl_logic_vector(7 downto 0);
        i_g             : in     vl_logic_vector(7 downto 0);
        i_b             : in     vl_logic_vector(7 downto 0);
        o_hav           : out    vl_logic;
        o_vav           : out    vl_logic;
        o_y             : out    vl_logic_vector(7 downto 0)
    );
end rgb2gray;
