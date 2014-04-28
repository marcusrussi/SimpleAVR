

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY SimpleAVR IS 
	PORT
	(
		CLK_IN    : IN  STD_LOGIC;
		RESET_IN  : IN  STD_LOGIC;
		LEDR      : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		LEDG      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0      : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX1      : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX2      : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX3      : OUT STD_LOGIC_VECTOR(6 downto 0)
	);
END SimpleAVR;

ARCHITECTURE SimpleAVR_arch OF SimpleAVR IS 

-- Clock Divider
COMPONENT clock_divider IS
	PORT(RESET : in std_logic;
		 CLK_50MHz   : in std_logic;  -- 50 Mhz clock
		 CLK_1KHz : out std_logic;  --  1 KHz clock
		 CLK_100Hz : out std_logic; -- 100 Hz clock
		 CLK_10Hz : out std_logic; -- 10 Hz clock
		 CLK_1Hz : out std_logic -- 1 Hz clock
		 );
END COMPONENT;

-- Progarm Counter
COMPONENT PC IS 
	PORT
	(
		CLK_IN    : IN STD_LOGIC;
		RESET_IN  : IN STD_LOGIC;
		PC_in     : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		PC_out    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

-- Data Memory
COMPONENT single_port_ram_with_init IS
	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 2**8 - 1;
		data	: in std_logic_vector((8-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((8 -1) downto 0);
		hex   : out std_logic_vector(27 downto 0)
	);
END COMPONENT;

-- Register File
COMPONENT RegFile IS 
	PORT
	(
		CLK_IN    : IN STD_LOGIC;
		RESET_IN  : IN STD_LOGIC;
		We        : IN STD_LOGIC;
		A1        : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		A2        : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		A3        : IN STD_LOGIC_VECTOR(4 downto 0);
		WD3       : IN STD_LOGIC_VECTOR(7 downto 0);
		RD1       : OUT STD_LOGIC_VECTOR(7 downto 0);
		RD2       : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END COMPONENT;

-- ALU
COMPONENT ALU IS 
	PORT
	(
		CLK_IN    : IN STD_LOGIC;
		RESET_IN  : IN STD_LOGIC;
		Sel       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SrcA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		SrcB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		DataOut   : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END COMPONENT;

-- Program Memory
COMPONENT single_port_rom IS
	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 2**8 - 1;
		q		: out std_logic_vector((16 -1) downto 0)
	);
END COMPONENT;


-- Hex display signals
SIGNAL   hex_disp  :  STD_LOGIC_VECTOR(27 downto 0);

-- Clock Divider signals
SIGNAL	CLOCK_1Hz :  STD_LOGIC;
SIGNAL 	CLOCK_10HZ : STD_LOGIC;
SIGNAL   CLOCK_100HZ: STD_LOGIC;
SIGNAL	CLOCK_1000HZ : STD_LOGIC;

-- Program Memory signals
SIGNAL	Inst_addr :  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL   Inst      :  STD_LOGIC_VECTOR(15 downto 0);

-- Data Memory signals

SIGNAL   DM_addr   :  STD_LOGIC_VECTOR(6 downto 0);
SIGNAL   DM_in     :  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL   DM_we     :  STD_LOGIC;
SIGNAL   DM_out    :  STD_LOGIC_VECTOR(7 downto 0);

-- Register File signals

SIGNAL RF_We  :  STD_LOGIC;
SIGNAL RF_A1  :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RF_A2  :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RF_A3  :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RF_WD3 :  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL RF_RD1 :  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL RF_RD2 :  STD_LOGIC_VECTOR(7 downto 0);


-- ALU signals
SIGNAL ALU_SELECT : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL ALU_OUT : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL ALU_INPUT1 : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL ALU_INPUT2 : STD_LOGIC_VECTOR(7 downto 0);
 
-- Program Counter signals
SIGNAL PC_INPUT : STD_LOGIC_VECTOR(11 downto 0); 

-- Control Unit Signals
SIGNAL LOAD : STD_LOGIC;
SIGNAL WRITE_INPUT : STD_LOGIC_VECTOR(7 downto 0);

BEGIN 

HEX3 <= hex_disp(27 downto 21);
HEX2 <= hex_disp(20 downto 14);
HEX1 <= hex_disp(13 downto 7);
HEX0 <= hex_disp(6 downto 0);

LEDG <= Inst_addr;
LEDR <= ALU_OUT(4 downto 0) & RF_WD3(4 downto 0);

CLK_GEN : clock_divider
PORT MAP(
RESET => RESET_IN, 
CLK_50MHz => CLK_IN,
CLK_1KHz => CLOCK_1000HZ,  -- 1 KHz clock
CLK_100Hz => CLOCK_100HZ,  -- 100 Hz clock
CLK_10Hz => CLOCK_10HZ,    -- 10 Hz clock
CLK_1Hz => CLOCK_1HZ       -- 1 Hz clock

);

Program_Memory : single_port_rom 
	port map 
	(
		clk	=> CLOCK_1Hz,
		addr	=> to_integer(unsigned(Inst_addr)),
		q		=> Inst
	);
	
Data_Memory : single_port_ram_with_init
   port map
	(
		clk	=> CLOCK_1Hz,
		addr	=> to_integer(unsigned(DM_addr)),
		data	=> DM_in,
		we		=> DM_we,
		q		=> DM_out,
		hex   => hex_disp
	);

Register_File : RegFile
	port map
	(
		CLK_IN    => CLOCK_1Hz,
		RESET_IN  => RESET_IN,
		We        => RF_We,
		A1        => RF_A1,
		A2        => RF_A2,
		A3        => RF_A3,
		WD3       => RF_WD3,
		RD1       => RF_RD1,
		RD2       => RF_RD2
	);
	
ALU_Instance : ALU
        port map
        (
                CLK_IN    => CLOCK_1HZ,
                RESET_IN  => RESET_IN,
                Sel       => ALU_SELECT,
                SrcA      => ALU_INPUT1,
                SrcB      => ALU_INPUT2,
                DataOut   => ALU_OUT
        );
       
PC_Instance : PC
        port map
        (
                CLK_IN    => CLOCK_1HZ,
                RESET_IN  => RESET_IN,
                PC_in     => PC_INPUT,
                PC_out    => Inst_addr
                
        );

----------------------------------------------------------------
--Opcodes
-- LDS (Load)					1010 0kkk dddd kkkk
-- STD (Store)					1010 1kkk dddd kkkk
-- Nop (No Op)					0000 0000 0000 0000
-- ADD (Add)					0000 11rd dddd rrrr
-- RJMPT (Relative Jump)	1100 kkkk kkkk kkkk
-- AND (Logical And)       0010 00rd dddd rrrr
-- OR (Logical Or)         0010 10rd dddd rrrr
-- XOR (Exclusive Or)      0010 01rd dddd rrrr
-- LDS (Load)						1010 0kkk dddd kkkk
-- STD (Store)						1010 1kkk dddd kkkk
-- Nop (No Op)						0000 0000 0000 0000
-- ADD (Add)						0000 11rd dddd rrrr
--	SUB (Subtract)					0001 10rd dddd rrrr
-- LSL (Logical Shift Left)	0000 11dd dddd dddd
-- LSR (Logical Shift Right)	1001 010d dddd 0110
-- RJMPT (Relative Jump)		1100 kkkk kkkk kkkk
-- AND (Logical And)       0010 00rd dddd rrrr
-- OR (Logical Or)         0010 10rd dddd rrrr
-- XOR (Exclusive Or)      0010 01rd dddd rrrr
	
decode_function	: process (RESET_IN, Inst)
begin 
		RF_We <= '0';
		DM_we <= '0';
      -- reset state when board powers on
			if (RESET_IN = '0') then
			
			--Program counter signals
			PC_INPUT <= "000000000000";
			
			--Register file signals
			RF_A1 <= "00000";
			RF_A2 <= "00000";
			RF_A3 <= "00000";
			RF_WD3 <= "00000001";
			RF_We <= '0';
			
			--ALU signals
			ALU_SELECT <= "0000";
			
			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
			
			--Add-----------------------------------------------------------------
			elsif (Inst(15 downto 10) = "000011") then
			
			--Program counter signals 
			PC_INPUT <= "000000000000";
			
			--Register File signals
			RF_A1 <= Inst(9) & Inst(3 downto 0); 
			RF_A2 <= Inst(8 downto 4);
			RF_A3 <= Inst(8 downto 4);
			RF_We <= '1';
			RF_WD3 <= ALU_OUT;
			
			--ALU Signals
			ALU_SELECT <= "0001";
			ALU_INPUT1 <= RF_RD1;
			ALU_INPUT2 <= RF_RD2;

			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
		
			--Subtract-----------------------------------------------------------------
			elsif (Inst(15 downto 10) = "000110") then
			
			--Program counter signals 
			PC_INPUT <= "000000000000";
			
			--Register File signals
			RF_A1 <= Inst(9) & Inst(3 downto 0); 
			RF_A2 <= Inst(8 downto 4);
			RF_A3 <= Inst(8 downto 4);
			RF_We <= '1';
			RF_WD3 <= ALU_OUT;
			
			--ALU Signals
			ALU_SELECT <= "0010";
			ALU_INPUT1 <= RF_RD1;
			ALU_INPUT2 <= RF_RD2;

			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
		
			--Logical Shift Right-----------------------------------------------------------------
			elsif ((Inst(15 downto 9) = "1001010")) then
				if(Inst(3 downto 0) = "0110") then
				
				--Program counter signals 
				PC_INPUT <= "000000000000";
			
				--Register File signals
				RF_A1 <= Inst(8 downto 4);
				RF_A3 <= Inst(8 downto 4);
				RF_We <= '1';
				RF_WD3 <= ALU_OUT;
				
				--ALU Signals
				ALU_SELECT <= "0101";
				ALU_INPUT1 <= RF_RD1;

				--Data Memory Signals
				DM_addr <= "0000000";
				DM_in <= "00000000";
				DM_we <= '0';
				
				end if;
			
			--Store--------------------------------------------------------------------------
			elsif(Inst(15 downto 11) = "10101") then
			
			--Program Counter signals
			PC_INPUT <= "000000000000";
			
			--Register file signals
			RF_We <= '0';
			RF_A1 <= STD_LOGIC_VECTOR("1" & Inst(7 downto 4));
			RF_A2 <= "00000";
			RF_A3 <= "00000";
			RF_WD3 <= "00000010";
			
			--ALU Signals
			ALU_SELECT <= "0000";
			
			--Data Memory Signals
			DM_we <= '1';
			DM_addr <= Inst(10 downto 8) & Inst(3 downto 0);
			DM_in <= RF_RD1;
			
			--Load----------------------------------------------------------------------
			elsif (Inst(15 downto 11) = "10100") then
			
			--Program Counter Signals
			PC_INPUT <= "000000000000";
			
			--Register File Signals
			RF_A1 <= "00000";
			RF_A2 <= "00000";
			RF_A3 <= STD_LOGIC_VECTOR("1" & Inst(7 downto 4));
			RF_We <= '1';
			RF_WD3 <= DM_out;
			
			--ALU Signals
			ALU_SELECT <= "0000";
			
			--Data Memory Signals
			DM_in <= "00000000";
			DM_we <= '0';
			DM_addr <= Inst(10 downto 8) & Inst(3 downto 0);
			
			--Jump-----------------------------------------------------------
			elsif (Inst(15 downto 12) = "1100") then
			
			--Program Counter Signals
			PC_INPUT <= Inst(11 downto 0);
			
			--Register file signals
			RF_A1 <= "00000";
			RF_A2 <= "00000";
			RF_A3 <= "00000";
			RF_WD3 <= "00000100";
			RF_We <= '0';
			
			--ALU signals
			ALU_SELECT <= "0000";
			
			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
			
			--And------------------------------------------------------------
			elsif (Inst(15 downto 10) = "001000") then
			
			--Program counter signals 
			PC_INPUT <= "000000000000";
			
			--Register File signals
			RF_A1 <= Inst(9) & Inst(3 downto 0); 
			RF_A2 <= Inst(8 downto 4);
			RF_A3 <= Inst(8 downto 4);
			RF_We <= '1';
			RF_WD3 <= ALU_OUT;
			
			--ALU Signals
			ALU_SELECT <= "0110";
			ALU_INPUT1 <= RF_RD1;
			ALU_INPUT2 <= RF_RD2;

			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
			
			--Or-------------------------------------------------------------
			elsif (Inst(15 downto 10) = "001010") then
			
			--Program counter signals 
			PC_INPUT <= "000000000000";
			
			--Register File signals
			RF_A1 <= Inst(9) & Inst(3 downto 0); 
			RF_A2 <= Inst(8 downto 4);
			RF_A3 <= Inst(8 downto 4);
			RF_We <= '1';
			RF_WD3 <= ALU_OUT;
			
			--ALU Signals
			ALU_SELECT <= "0111";
			ALU_INPUT1 <= RF_RD1;
			ALU_INPUT2 <= RF_RD2;

			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
			
			--Xor------------------------------------------------------------
			elsif (Inst(15 downto 10) = "001001") then
			
			--Program counter signals 
			PC_INPUT <= "000000000000";
			
			--Register File signals
			RF_A1 <= Inst(9) & Inst(3 downto 0); 
			RF_A2 <= Inst(8 downto 4);
			RF_A3 <= Inst(8 downto 4);
			RF_We <= '1';
			RF_WD3 <= ALU_OUT;
			
			--ALU Signals
			ALU_SELECT <= "1000";
			ALU_INPUT1 <= RF_RD1;
			ALU_INPUT2 <= RF_RD2;

			--Data Memory Signals
			DM_addr <= "0000000";
			DM_in <= "00000000";
			DM_we <= '0';
			
			--Nop-------------------------------------------------------------------
			else
		
			--Program counter signals
			PC_INPUT <= "000000000000";
			
			end if;
			

end process;
	
	
END SimpleAVR_arch;