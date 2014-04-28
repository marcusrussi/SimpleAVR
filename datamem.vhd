-- Quartus II VHDL Template
-- Single-port RAM with single read/write address and initial contents	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_ram_with_init is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 8
	);

	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0);
		hex   : out std_logic_vector(27 downto 0)
	);

end single_port_ram_with_init;

architecture rtl of single_port_ram_with_init is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	function init_ram
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
		end loop;
		
		
		-- INTIALIZE MEMORY
		tmp(0) := "00001011";
		tmp(1) := "00001101";
-- AND: expct.  "00001001" which is 9
--		tmp(2) := "00000010";
--		tmp(3) := "00000011";
--		tmp(4) := "00000100";
--		tmp(5) := "00000101";
--		tmp(6) := "00000110";
--		tmp(7) := "00000111";
--		tmp(8) := "00001000";
--		tmp(9) := "00001001";
		
		tmp(126) := "00000000";
		tmp(127) := "00000000";
		return tmp;
	end init_ram;	 

	-- Declare the RAM signal and specify a default value.	Quartus II
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	signal ram : memory_t := init_ram;

	-- Register to hold the address 
	signal addr_reg : natural range 0 to 2**ADDR_WIDTH-1;

	-- Seven Segment Decoder
	COMPONENT SevSegDec IS 
		PORT
		(
			IN_D :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			HEX  :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL hex32 : STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL hex10 : STD_LOGIC_VECTOR(7 downto 0);
	
begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(addr) <= data;
		end if;

		-- Register the address for reading
		addr_reg <= addr;
	end if;
	end process;

	q <= ram(addr);

	hex32 <= ram(126);
	hex10 <= ram(127);
	
	SevSegDec3: SevSegDec
	    port map
		 (
		 IN_D => hex32(7 downto 4),
		 HEX => hex(27 downto 21)
		 );

	SevSegDec2: SevSegDec
	    port map
		 (
		 IN_D => hex32(3 downto 0),
		 HEX => hex(20 downto 14)
		 );
		 
	SevSegDec1: SevSegDec
	    port map
		 (
		 IN_D => hex10(7 downto 4),
		 HEX => hex(13 downto 7)
		 );
		 
	SevSegDec0: SevSegDec
	    port map
		 (
		 IN_D => hex10(3 downto 0),
		 HEX => hex(6 downto 0)
		 );
		 
end rtl;
