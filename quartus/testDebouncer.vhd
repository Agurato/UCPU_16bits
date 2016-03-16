library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY testDebouncer IS
	PORT(KEY: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			CLOCK_50: IN STD_LOGIC;
			LEDR: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			LEDG: OUT STD_LOGIC_VECTOR(8 DOWNTO 0));
END ENTITY;

ARCHITECTURE testDebouncer_bhv OF testDebouncer IS
	signal counter: INTEGER := 0;
	signal so: STD_LOGIC;

	COMPONENT debouncer is
		port(s_i, clk: IN std_logic;
			s_o: OUT std_logic);
	END COMPONENT;	
	
BEGIN
	
	debounc0 : debouncer PORT MAP (KEY(0), CLOCK_50, so);
	LEDR <= STD_LOGIC_VECTOR(to_unsigned(counter, LEDR'LENGTH));
	LEDG(0) <= KEY(0);
	LEDG(1) <= so;
	
	PROCESS(so)
	BEGIN
		if so'event and so = '1' then
			counter <= counter + 1;
		END IF;
	END PROCESS;
	
END ARCHITECTURE;