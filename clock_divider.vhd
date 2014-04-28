-------------------------------------------------------------
-- 
-- filename:  clock_divider.vhd
-- date:  Revised 10 Feb 13
--
-- date: Revised Feb. 17, 2014 by Jakub Szefer (Yale EE)
--
-- by:  COL Bob Sadowski, robert.sadowski@usma.edu
-- course:  EENG201b Intro to Comp Arch, Yale University
-- department:  Department of Electrical Engineering
-- institution:  United States Military Academy, West Point, New York, USA
-- 
-- This version creates an active high clock for half of the duty cycle.
--
-- This clock_divider takes in a 50Mhz clock signal and outputs a 
-- 1KHz, 100Hz, 10Hz, and 1Hz clock signal.

-------------------------------------------------------------
--  There is error with 10Hz and 1Hz clock signal.  
--  What are their actual frequencies?
-------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY clock_divider IS
	PORT(RESET : in std_logic;
		 CLK_50MHz   : in std_logic;  -- 50 Mhz clock
		 CLK_1KHz : out std_logic;  --  1 KHz clock
		 CLK_100Hz : out std_logic; -- 100 Hz clock
		 CLK_10Hz : out std_logic; -- 10 Hz clock
		 CLK_1Hz : out std_logic -- 1 Hz clock
		 );
END clock_divider;

ARCHITECTURE clk_div_function OF clock_divider IS

	SIGNAL CLOCK_COUNTER : std_logic_vector(14 downto 0);
	SIGNAL HUNDREDTHS_COUNTER : std_logic_vector(3 downto 0);
	SIGNAL TENTHS_COUNTER : std_logic_vector(3 downto 0);
	SIGNAL SECONDS_COUNTER : std_logic_vector(3 downto 0);
	
	SIGNAL CLK_1Khz_INT : std_logic;
	SIGNAL CLK_100Hz_INT : std_logic;
	SIGNAL CLK_10Hz_INT : std_logic;
	SIGNAL CLK_1Hz_INT : std_logic;

BEGIN

	proc_CLK_1Khz : process (RESET, CLK_50Mhz) 
	begin -- process
		if (RESET = '0') then
			CLOCK_COUNTER <= "000000000000000";
			CLK_1KHz_INT <= '1';
		elsif (CLK_50MHz'event and CLK_50MHz = '1') then
			CLOCK_COUNTER <= CLOCK_COUNTER + 1;
			if (CLOCK_COUNTER = 24999) then
				CLK_1KHz_INT <= not CLK_1KHz_INT;
				CLOCK_COUNTER <= "000000000000000";
			end if;
		end if;
	end process;  -- proc_CLK_1Khz
	
	proc_CLK_100Hz : process (RESET, CLK_1KHz_INT)
	begin
		if (RESET = '0') then
			HUNDREDTHS_COUNTER <= "0000";
			CLK_100Hz_INT <= '1';
		elsif (CLK_1KHz_INT'event and CLK_1KHz_INT = '1') then
			HUNDREDTHS_COUNTER <= HUNDREDTHS_COUNTER + 1;
			if (HUNDREDTHS_COUNTER = 4) then
				CLK_100Hz_INT <= not CLK_100Hz_INT;
				HUNDREDTHS_COUNTER <= "0000";
			end if;
		end if;
	end process;  -- proc_CLK_100Hz
	
	proc_CLK_10Hz : process (RESET, CLK_100Hz_INT)
	begin
		if (RESET = '0') then
			TENTHS_COUNTER <= "0000";
			CLK_10Hz_INT <= '1';
		elsif (CLK_100Hz_INT'event and CLK_100Hz_INT = '1') then
			TENTHS_COUNTER <= TENTHS_COUNTER + 1;
			if (TENTHS_COUNTER = 9) then
				CLK_10Hz_INT <= not CLK_10Hz_INT;
				TENTHS_COUNTER <= "0000";
			end if;
		end if;
	end process;  -- proc_CLK_10Hz	

	proc_CLK_1Hz : process (RESET, CLK_10Hz_INT)
	begin

		if (RESET = '0') then
			SECONDS_COUNTER <= "0000";
			CLK_1Hz_INT <= '1';
		elsif (CLK_10Hz_INT'event and CLK_10Hz_INT = '1') then
			SECONDS_COUNTER <= SECONDS_COUNTER + 1;
			if (SECONDS_COUNTER = 4) then
				CLK_1Hz_INT <= not CLK_1Hz_INT;
				SECONDS_COUNTER <= "0000";
			end if;
		end if;
		
	end process;  -- proc_CLK_1Hz		

	CLK_1KHz <= CLK_1KHz_INT;
	CLK_100Hz <= CLK_100Hz_INT;
	CLK_10Hz <= CLK_10Hz_INT;
	CLK_1Hz <= CLK_1Hz_INT;

END clk_div_function;