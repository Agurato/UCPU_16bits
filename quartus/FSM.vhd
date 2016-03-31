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
	writeSource: OUT std_logic;
	DoneSignal, idleSignal : OUT std_logic;
	countClock : OUT std_logic_vector(7 downto 0);
	clk: IN std_logic;
	CODOPout : OUT std_logic_vector(3 downto 0)
);

END ControlUnit;

ARCHITECTURE Behavior OF ControlUnit IS
TYPE state_t IS (idle, move, moveImmediate, moveImmediate2, operation, done);

SIGNAL CODOP_saved : STD_LOGIC_VECTOR(NBITS-1 downto 0);

BEGIN
	PROCESS(clk, reset)
	VARIABLE state : state_t;
	BEGIN
		--reset
		if(reset = '0') then
			CODOPSave <= '1';
			CODOPout <= CODOP(NBITS-1 downto NBITS-4);
			selA <= "1111"; -- A from In
			selB <= "1111"; -- B from In
			aluSel <= "111"; -- empty operation from alu
			selWrite <= "1111"; -- no write
			writeSource <= '0';
			
			DoneSignal <= '0';

			state := done;
			idleSignal <= '1';
			countClock <= "00000000";

		--idle
		elsif(RISING_EDGE(clk)  AND run = '1' AND state = idle) then
			--do things
			DoneSignal <= '0';
			--store CODOP
			CODOP_saved <= CODOP;
			CODOPSave <= '0';
			CODOPout <= CODOP(NBITS-1 downto NBITS-4);

			if(CODOP(NBITS-1 downto NBITS-4) = "0000") then
				state := move;
				countClock <= "00000001";
				
				selA <= CODOP(NBITS-9 downto NBITS-12);
				selB <= CODOP(NBITS-9 downto NBITS-12);
				aluSel <= "100"; -- AND or OR
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
				writeSource <= '0';
			
			elsif(CODOP(NBITS-1 downto NBITS-4) = "0001") then
				state := moveImmediate;
				countClock <= "00000010";
				
				selA <= "1111";
				selA <= "1111";
				aluSel <= "100"; -- AND or OR
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
				writeSource <= '1';
				
			elsif(CODOP(NBITS-1) = '1') then
				state := operation;
				countClock <= "00000100";
				
				selA <= CODOP(NBITS-5 downto NBITS-8);
				selB <= CODOP(NBITS-9 downto NBITS-12);
				aluSel <= CODOP(NBITS-2 downto NBITS-4);
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
				writeSource <= '0';
				
			end if;
			
			idleSignal <= '0';

		--move
		elsif(RISING_EDGE(clk) AND run = '1' AND state = move) then

			state := done;
			countClock <= "00001111";
			idleSignal <= '1';
			CODOPSave <= '1';

		--moveImmediate1: wait clock redirect
		elsif(RISING_EDGE(clk) AND run = '1' AND state = moveImmediate) then

			state := moveImmediate2;
			countClock <= "00000011";
			idleSignal <= '0';

		--moveImmediate2: memorize
		elsif(RISING_EDGE(clk) AND run = '1' AND state = moveImmediate2) then
		
			state := done;
			countClock <= "00001111";
			idleSignal <= '1';
			CODOPSave <= '1';

		--operation
		elsif(RISING_EDGE(clk) AND run = '1' AND state = operation) then

			state := done;
			countClock <= "00001111";
			idleSignal <= '1';
			CODOPSave <= '1';

		--DONE
		elsif(RISING_EDGE(clk) AND run = '1' AND state = done) then
			selA <= "1111";
			selB <= "1111";
			aluSel <= "111";
			selWrite <= "1111";
			DoneSignal <= '1';
			writeSource <= '0';

			state := idle;
			countClock <= "00000000";
			idleSignal <= '1';

		end if;
	END PROCESS;
END Behavior;