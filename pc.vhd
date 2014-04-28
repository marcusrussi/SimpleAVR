

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

ENTITY PC IS 
	PORT
	(
		CLK_IN    : IN STD_LOGIC;
		RESET_IN  : IN STD_LOGIC;
		PC_in     : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		PC_out    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END PC;

ARCHITECTURE PC_arch OF PC IS 

SIGNAL PC : integer;
SIGNAL INCREMENT : integer;


BEGIN 

clocked_registers : process (RESET_IN, CLK_IN, INCREMENT)
begin 

		
      -- reset state when board powers on
		if (RESET_IN = '0') then
		   PC <= 0;
			
	   -- actions to perform on each rising edge of the clock
		elsif (rising_edge(CLK_IN)) then
			--INCREMENT is only nonzero during a jump instruction
			PC <= PC + 1 + INCREMENT;
			
		end if;
		PC_out <= STD_LOGIC_VECTOR(TO_SIGNED(PC,8));
		INCREMENT <= TO_INTEGER(SIGNED(PC_in));
		
end process;
		
END PC_arch;