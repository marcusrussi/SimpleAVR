 
 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
 
 
ENTITY RegFile IS
 
        generic
        (
                DATA_WIDTH : natural := 8;
                ADDR_WIDTH : natural := 5
        );
 
        PORT
        (
                CLK_IN    : IN STD_LOGIC;
                RESET_IN  : IN STD_LOGIC;
                We        : IN STD_LOGIC;
                A1        : in natural range 0 to 2**ADDR_WIDTH - 1;
                A2        : in natural range 0 to 2**ADDR_WIDTH - 1;
                A3        : in natural range 0 to 2**ADDR_WIDTH - 1;
                WD3       : IN STD_LOGIC_VECTOR(7 downto 0);
                RD1       : OUT STD_LOGIC_VECTOR(7 downto 0);
                RD2       : OUT STD_LOGIC_VECTOR(7 downto 0)
        );
END RegFile;
 
ARCHITECTURE RegFile_arch OF RegFile IS
	--an array of size 32 with vectors of size 8
    type reg_array is array (0 to 31) of std_logic_vector(7 downto 0);
    signal reg_file : reg_array;
     
        begin process(CLK_IN, we, A3, WD3)
        begin
				if(rising_edge(CLK_IN)) then
                if(we = '1') then
                        reg_file(A3) <= WD3;
                end if;
				end if;		  
        end process;
             
					  
		  RD1 <= reg_file(A1);
        RD2 <= reg_file(A2);
		  
END RegFile_arch;