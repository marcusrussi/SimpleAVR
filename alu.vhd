

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

--Opcodes for ALU
--Nop 								----> 0000  (Done)
--Add without carry 				----> 0001	(Done)

--Subtract without carry 		----> 0010	(Mike)
--Multiply signed 				----> 0011	(Mike)
--Logical Shift Left				----> 0100	(Mike)
--Logical Shift Right 			----> 0101	(Mike)

--Logical AND						----> 0110	(Marcus)
--Logical OR						----> 0111	(Marcus)
--Exclusive OR  					----> 1000	(Marcus)



ENTITY ALU IS 
	PORT
	(
		CLK_IN    : IN STD_LOGIC;
		RESET_IN  : IN STD_LOGIC;
		Sel       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SrcA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		SrcB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DataOut   : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END ALU;

ARCHITECTURE ALU_arch OF ALU IS 

SIGNAL INPUT_A : INTEGER;
SIGNAL INPUT_B : INTEGER;

BEGIN 

INPUT_A <= TO_INTEGER(UNSIGNED(SrcA)); 
INPUT_B <= TO_INTEGER(UNSIGNED(SrcB));


add : process (Sel, RESET_IN, INPUT_A, INPUT_B)
begin 
      -- reset state when board powers on
		if (RESET_IN = '0') then
		   DataOut <= "00000000";
			
	   -- Actions the ALU can perform
		else
			if(Sel(3 downto 0) = "1111") then
				DataOut <= STD_LOGIC_VECTOR(TO_UNSIGNED((INPUT_A + INPUT_B),8));
			end if;
		end if;
	
		
end process;

END ALU_arch;