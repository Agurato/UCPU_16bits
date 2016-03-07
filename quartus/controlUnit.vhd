LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ControlUnit IS
GENERIC(NBITS : positive := 16);
PORT (
	run, reset: IN std_logic;
	CODOP: IN std_logic_vector(NBITS-1 downto 0);
	CODOPSave : OUT std_logic;
	selA, selB : OUT std_logic_vector(3 downto 0);
	aluSel : OUT std_logic_vector(2 downto 0);
	selWrite : OUT std_logic_vector(3 downto 0);
	Done : OUT std_logic;
);
END MUX_2_1;

ARCHITECTURE Behavior OF ControlUnit IS
TYPE state_t IS (idle, init, move, moveImmediate, moveImmediate2, operation, done);
Signal state : state_t;
BEGIN
	PROCESS(clk)
	BEGIN
		--reset
		if(reset = '0') then state := init;
		
		--init
		else if(clk = '1' AND state = init) then
			CODOPSave <= '1';
			selA <= "1111"; -- A from In
			selB <= "1111"; -- B from In
			aluSel <= "111"; -- empty operation from alu
			selWrite <= "1111"; -- no write
			Done <= '0';
			
			state := idle;
		
		--idle
		else if(clk = '1'  AND run = '1' AND state = idle) then
			--do things
			--store CODOP
			CODOPSave <= '0';
			
			if(CODOP(NBITS-1 downto NBITS-4) = "0000") then
				state := move;
			else if(CODOP(NBITS-1 downto NBITS-4) = "0001") then
				state := moveImmediate;
			else if(CODOP(NBITS-1) = '1') then
				state := operation;
			end if;
			
		--move
		else if(clk = '1'  AND run = '1' AND state = move) then
			selA <= CODOP(NBITS-9 downto NBITS-12);
			selB <= CODOP(NBITS-9 downto NBITS-12);
			aluSel <= "100"; -- AND or OR
			selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
			state := done;
			
		--moveImmediate1: wait clock redirect
		else if(clk = '1'  AND run = '1' AND state = moveImmediate) then
			selA <= "1111";
			selA <= "1111";
			aluSel <= "100"; -- AND or OR
			selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
			state := moveImmediate2
			
		--moveImmediate2: memorize
		else if(clk = '1'  AND run = '1' AND state = moveImmediate2) then
			state := done;
			
		--operation
		else if(clk = '1'  AND run = '1' AND state = operation) then
			selA <= CODOP(NBITS-5 downto NBITS-8);
			selB <= CODOP(NBITS-9 downto NBITS-12);
			aluSel <= CODOP(NBITS-2 downto NBITS-4);
			selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
			state := done;

		--DONE
		else if(clk = '1'  AND run = '1' AND state = done) then
			CODOPSave <= '1';
			selA <= "1111";
			selB <= "1111";
			aluSel <= "111";
			selWrite <= "1111";
			Done <= '1';
			
			state := idle;
			
		end if;
	END PROCESS;
END Behavior;