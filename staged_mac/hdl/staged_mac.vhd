-------------------------------------------------------------------------
-- Matthew Dwyer
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- staged_mac.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a basic staged axi-stream mac unit. It
-- multiplies two integer values together and accumulates them.
--
-- NOTES:
-- 10/25/21 by MPD::Inital template creation
-- 9/5/25 by CWS::Minor changes to remove Qx.x
-------------------------------------------------------------------------

library work;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity staged_mac is
  generic(
      -- Parameters of mac
      C_DATA_WIDTH : integer := 8
    );
	port (
        ACLK	: in	std_logic;
		ARESETN	: in	std_logic;       

        -- AXIS slave data interface
		SD_AXIS_TREADY	: out	std_logic;
		SD_AXIS_TDATA	: in	std_logic_vector(C_DATA_WIDTH*2-1 downto 0);  -- Packed data input
		SD_AXIS_TLAST	: in	std_logic;
        SD_AXIS_TUSER   : in    std_logic;  -- Should we treat this first value in the stream as an inital accumulate value?
		SD_AXIS_TVALID	: in	std_logic;
        SD_AXIS_TID     : in    std_logic_vector(7 downto 0);

        -- AXIS master accumulate result out interface
		MO_AXIS_TVALID	: out	std_logic;
		MO_AXIS_TDATA	: out	std_logic_vector(31 downto 0);
		MO_AXIS_TLAST	: out	std_logic;
		MO_AXIS_TREADY	: in	std_logic;
		MO_AXIS_TID     : out   std_logic_vector(7 downto 0)
    );

-- ME: just letting the synthesis tool know that ACLK is clock, so it can route it diffrently
attribute SIGIS : string; 
attribute SIGIS of ACLK : signal is "Clk"; 

end staged_mac;


architecture behavioral of staged_mac is
    -- Internal Signals
	
	
	-- Mac state
    type STATE_TYPE is (WAIT_FOR_VALUES);
    signal state : STATE_TYPE;

	-- Debug signals, make sure we aren't going crazy
    signal mac_debug : std_logic_vector(31 downto 0);

    -- Intended behaviour of my circuit
    -- 1. When last is detected, Accumulate reg_outister, which is 32 bits should be reset

    -- MY SIGNALS: 
    signal s_last_in_reg_out : std_logic;
    signal s_data_in_reg_out : std_logic_vector(C_DATA_WIDTH*2-1 downto 0);
    signal s_valid_in_reg_out: std_logic;
    signal s_user_in_reg_out: std_logic;

    signal s_accumulator_reg_out : std_logic_vector(31 downto 0);
    signal s_delayed_last_in: std_logic;

    signal s_adder_operand_a : std_logic_vector(31 downto 0);
    signal s_adder_operand_b : std_logic_vector(31 downto 0);
    signal s_adder_out       : std_logic_vector(31 downto 0);

    signal s_ready_out : std_logic;


begin
    -- Assignments
    MO_AXIS_TDATA  <= s_accumulator_reg_out; -- accumulator's reg_out is the output data
    MO_AXIS_TVALID <= s_delayed_last_in;
    -- Keep accumulating until accumulate data is valid (completed accumulation) and the slave is not ready to consume
    s_ready_out <= not s_delayed_last_in or MO_AXIS_TREADY;
    SD_AXIS_TREADY <= s_ready_out;

    s_adder_operand_a <= s_accumulator_reg_out when (s_delayed_last_in = '0') else (others => '0'); 

    s_adder_operand_b <= (31 downto C_DATA_WIDTH*2 => '0') &
                         std_logic_vector(unsigned(s_data_in_reg_out(C_DATA_WIDTH*2-1 downto C_DATA_WIDTH)) * unsigned(s_data_in_reg_out(C_DATA_WIDTH-1 downto 0)))
                         when (s_valid_in_reg_out = '1') else (others => '0'); 

    s_adder_out <= std_logic_vector(unsigned(s_adder_operand_a) + unsigned(s_adder_operand_b));

	
	-- Debug Signals
    mac_debug <= x"00000000";  -- Double checking sanity

    process(ACLK) is
    begin
        if rising_edge(ACLK) then
            if ARESETN = '0' then

                s_delayed_last_in <= '0';
                s_last_in_reg_out <= '0';
                s_valid_in_reg_out <= '0';

                s_data_in_reg_out <= (others => '0');
                s_accumulator_reg_out <= (others => '0'); -- set the accumulator to 0

            elsif s_ready_out = '1' then
                s_last_in_reg_out <= SD_AXIS_TLAST;
                s_delayed_last_in <= s_last_in_reg_out and s_valid_in_reg_out;

                s_valid_in_reg_out <= SD_AXIS_TVALID;
                s_data_in_reg_out <= SD_AXIS_TDATA;
                s_user_in_reg_out <= SD_AXIS_TUSER;

		if (s_user_in_reg_out = '0') then
                	s_accumulator_reg_out <= s_adder_out;
		else
			s_accumulator_reg_out <= x"0000" & s_data_in_reg_out;
		end if;
            end if;
        end if;
    end process;

end architecture behavioral;
