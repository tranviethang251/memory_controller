library verilog;
use verilog.vl_types.all;
entity Filter_2 is
    generic(
        DATA_WIDTH      : integer := 8;
        WIDTH_IMAG      : integer := 4;
        HEIGHT_IMAG     : integer := 4;
        WEIGHT          : integer := 2
    );
    port(
        clk             : in     vl_logic;
        rstb            : in     vl_logic;
        i_hav           : in     vl_logic;
        i_vav           : in     vl_logic;
        data_in         : in     vl_logic_vector;
        wr_file         : out    vl_logic;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_IMAG : constant is 1;
    attribute mti_svvh_generic_type of HEIGHT_IMAG : constant is 1;
    attribute mti_svvh_generic_type of WEIGHT : constant is 1;
end Filter_2;
