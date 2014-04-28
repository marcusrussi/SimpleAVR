-- Seven Segment Decoder Module

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

ENTITY SevSegDec IS 
	PORT
	(
		IN_D :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		HEX  :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END SevSegDec;

ARCHITECTURE SevSeg_beh OF SevSegDec IS 

BEGIN 
 
WITH IN_D SELECT -- this will create a MUX structure
HEX <=  "1000000" WHEN X"0",
        "1111001" WHEN X"1",
	     "0100100" WHEN X"2",
	     "0110000" WHEN X"3", 
	     "0011001" WHEN X"4", 
	     "0010010" WHEN X"5", 
	     "0000010" WHEN X"6",
	     "1111000" WHEN X"7",  
	     "0000000" WHEN X"8", 
	     "0011000" WHEN X"9", 
	     "0001000" WHEN X"A", -- A
	     "0000011" WHEN X"B", -- B
	     "0100111" WHEN X"C", -- C
	     "0100001" WHEN X"D", -- D
	     "0000110" WHEN X"E", -- E
	     "0001110" WHEN X"F", -- F
	     "1111111" WHEN OTHERS; -- blank for others
  
END SevSeg_beh;