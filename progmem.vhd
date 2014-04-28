-- Quartus II VHDL Template
-- Single-Port ROM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_rom is

	generic 
	(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 8
	);

	port 
	(
		clk	: in std_logic;
		addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end entity;

architecture rtl of single_port_rom is

	-- Build a 2-D array type for the RoM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	function init_rom
		return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
		end loop;
		
		
		-- INTIALIZE MEMORY
		tmp(0) := "0101000000000000"; -- load mem. addr. 0 into register 16
		tmp(1) := "0101000000010001"; -- load mem. addr. 1 into register 17
		tmp(2) := "0000000000000000"; -- nop
		tmp(3) := "0000000000000000"; -- nop
		tmp(4) := "0000000000000000"; -- nop, jump to this instruction
		tmp(5) := "0000111100000001"; -- add register 16 and 17, store to 16
		tmp(6) := "0101111100001111"; -- store reg 16 into mem addr 127
		tmp(7) := "0000000000000000"; -- nop
		tmp(8) := "0000000000000000"; -- nop
		tmp(9) := "1100111111111010"; -- jump to PC +1 = 3

		return tmp;
	end init_rom;	 

	-- Declare the ROM signal and specify a default value.	Quartus II
	-- will create a memory initialization file (.mif) based on the 
	-- default value.
	signal rom : memory_t := init_rom;

begin

--	process(clk)
--	begin
--	if(rising_edge(clk)) then
		q <= rom(addr);
--	end if;
--	end process;

end rtl;
