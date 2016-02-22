LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UCPU_16bits IS
PORT (
	
	SW : in STD_LOGIC_VECTOR(17 downto 0);
	LEDR : out STD_LOGIC_VECTOR(17 downto 0);
	LEDG: out STD_LOGIC_VECTOR(7 downto 0);
	HEX0: out STD_LOGIC_VECTOR(0 to 6)
);
END UCPU_16bits;

ARCHITECTURE Behavior of UCPU_16bits IS
BEGIN

END ARCHITECTURE Behavior;