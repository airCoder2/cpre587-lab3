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

attribute SIGIS : string; 
attribute SIGIS of ACLK : signal is "Clk"; 

end staged_mac;


architecture behavioral of staged_mac is
    -- Internal Signals
	
	
	-- Mac state
    type STATE_TYPE is (LOAD_BIAS, ACCUMULATE);
    signal state : STATE_TYPE;
    
    signal s_accumulator: std_logic_vector(31 downto 0);
    signal s_valid      : std_logic;
    signal s_ready      : std_logic := '0';
	
begin
	
	-- Debug Signals
   
   process (ACLK) is
   begin 
    if rising_edge(ACLK) then  -- Rising Edge

      -- Reset values if reset is low
      if ARESETN = '0' then  -- Reset
        state   <= LOAD_BIAS;
        s_accumulator <= (others => '0');
        s_valid <= '0';

      else
        case state is  -- State
            when LOAD_BIAS =>
                -- if data is valid, and slave is ready to process new data
                if SD_AXIS_TVALID = '1' and s_ready = '1' then
                    state <= ACCUMULATE;

                    -- loading the bias, the first valid data
                    s_accumulator <= (31 downto C_DATA_WIDTH*2 => '0') & SD_AXIS_TDATA;

                    if SD_AXIS_TLAST = '1' then
                        s_valid <= '1';
                        state <= LOAD_BIAS;
                    end if;

                -- clear the s_valid signal to output if output was taken
                if s_ready = '1' then
                    s_valid <= '0';
                end if;
                end if;
			
            when ACCUMULATE =>
                -- is data is valid, then add it to what is already there (either bias or previous accumulations)
                if SD_AXIS_TVALID = '1' and s_ready = '1' then
		            s_accumulator <= std_logic_vector(unsigned(s_accumulator) + unsigned((31 downto C_DATA_WIDTH*2 => '0') & 
                                     std_logic_vector(unsigned(SD_AXIS_TDATA(C_DATA_WIDTH*2-1 downto C_DATA_WIDTH)) * unsigned(SD_AXIS_TDATA(C_DATA_WIDTH-1 downto 0)))));

                    -- if tlast is 1 then set valid_out to 1
                    if SD_AXIS_TLAST = '1' then
                        s_valid <= '1';
                        state <= LOAD_BIAS;
                    end if;
                end if;

                    
			-- Other stages go here	
			
            when others =>
                state <= LOAD_BIAS;
                -- Not really important, this case should never happen
                -- Needed for proper synthisis         
        end case;  -- State
      end if;  -- Reset

    end if;  -- Rising Edge
   end process;

        s_ready         <= not s_valid or MO_AXIS_TREADY;
		SD_AXIS_TREADY	<= s_ready;
		MO_AXIS_TVALID	<= s_valid;
		MO_AXIS_TLAST	<= s_valid;
		MO_AXIS_TDATA	<= s_accumulator;

end architecture behavioral;

