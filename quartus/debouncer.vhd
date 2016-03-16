library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY debouncer is
	port(s_i, clk: IN std_logic;
			s_o: OUT std_logic);
END ENTITY;

ARCHITECTURE debouncer_bhv OF debouncer IS
	signal tmp_s_i: STD_LOGIC;

BEGIN
	PROCESS(clk, s_i)
		variable counter: INTEGER := 0;
	BEGIN
		if RISING_EDGE(clk) then
			if s_i = tmp_s_i then
				if counter >= 50 then
					s_o <= tmp_s_i;
				else
					counter := counter + 1;
				end if;
			else
				tmp_s_i <= s_i;
				counter := 0;
			end if;
		end if;
		
	END PROCESS;
END ARCHITECTURE;