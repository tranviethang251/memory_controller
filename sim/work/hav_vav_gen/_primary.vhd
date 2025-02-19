library verilog;
use verilog.vl_types.all;
entity hav_vav_gen is
    generic(
        WIDTH           : integer := 1023;
        HEIGHT          : integer := 1023;
        H_BLANK         : integer := 205;
        V_BLANK         : integer := 205;
        H_COUNTER_LENGTH: integer := 11;
        V_COUNTER_LENGTH: integer := 11
    );
    port(
        clk             : in     vl_logic;
        rstb            : in     vl_logic;
        hav             : out    vl_logic;
        vav             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of HEIGHT : constant is 1;
    attribute mti_svvh_generic_type of H_BLANK : constant is 1;
    attribute mti_svvh_generic_type of V_BLANK : constant is 1;
    attribute mti_svvh_generic_type of H_COUNTER_LENGTH : constant is 1;
    attribute mti_svvh_generic_type of V_COUNTER_LENGTH : constant is 1;
end hav_vav_gen;
