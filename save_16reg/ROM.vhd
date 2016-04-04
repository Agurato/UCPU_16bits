-- ROM
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ROM IS
PORT (
	pointer : in STD_LOGIC_VECTOR(3 downto 0);
	instruction : out STD_LOGIC_VECTOR(15 downto 0)
);
END ROM;

ARCHITECTURE Behavior OF ROM IS
BEGIN
	with pointer select
	instruction <=	"0001000000000000" when "0000", -- mvi 3 => reg_0
					"0000000000000011" when "0001",
					"0000000000000011" when "0010",
					"0001000100000000" when "0011", -- mvi 6 => reg_1
					"0000000000000110" when "0100",
					"0000000000000110" when "0101",
					"1000000100010000" when "0110", -- add reg_1 <= reg_1 + reg_0
					"1000000100010000" when "0111",
					"1001000100010000" when "1000", -- sub reg_1 <= reg_1 - reg_0
					"1001000100010000" when "1001",
					"0000000100000000" when "1010", -- mv reg_1 <= reg_0
					"0000000100000000" when "1011",
					"1010000100010000" when "1100", -- mult reg_1 <= reg_1 * reg_0
					"1010000100010000" when "1101",
					"1111000100010000" when "1110", -- xor reg_1 <= reg_1 XOR reg_0
					"1111000100010000" when "1111";
END Behavior;

-- addr_store
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY addr_store IS
	PORT(
		JMP_addr : in STD_LOGIC_VECTOR(3 downto 0);
		reset, clk : in STD_LOGIC;
		increment : in STD_LOGIC;
		ptr_out : out STD_LOGIC_VECTOR(3 downto 0)
	);
END ENTITY addr_store;

ARCHITECTURE Behavior of addr_store IS

COMPONENT FULL_ADDER_N IS
generic( SIZE_FA : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
	c_in : in STD_LOGIC;
	s : out STD_LOGIC_VECTOR(SIZE_FA-1 downto 0);
	c_out : out STD_LOGIC
);
END COMPONENT;

SIGNAL ptr_addr : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL incr_addr : STD_LOGIC_VECTOR(3 downto 0);

BEGIN
	adder : FULL_ADDER_N GENERIC MAP(4) PORT MAP(a => ptr_addr, b => "0001", c_in => '0', s => incr_addr);

	process(clk, reset)
	BEGIN
		if reset = '1' then
				ptr_addr <= "0000";
		elsif RISING_EDGE(clk) then
			if increment = '1' then
				ptr_addr <= incr_addr;
			else
				ptr_addr <= JMP_addr;
			end if;
		end if;
	END PROCESS;

	ptr_out <= ptr_addr;
END ARCHITECTURE Behavior;
