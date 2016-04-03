LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSM IS
GENERIC(NBITS : positive := 16);
PORT (
	run, reset: IN std_logic;
	CODOP: IN std_logic_vector(NBITS-1 downto 0);
	clk: IN std_logic;
	
	selA, selB : OUT std_logic_vector(3 downto 0);
	aluSel : OUT std_logic_vector(2 downto 0);
	selWrite : OUT std_logic_vector(3 downto 0);
	writeSource: OUT std_logic;
	
	CODOPout : OUT std_logic_vector(3 downto 0);
	stateDisp : OUT std_logic_vector(7 downto 0)
);
END ENTITY FSM;

ARCHITECTURE Behavior OF FSM IS
TYPE state_t IS (idle, move, moveI, done);

BEGIN
	PROCESS(clk, reset)
	VARIABLE state : state_t;
	BEGIN
		if(reset = '0') then
			selA <= "1111";
			selB <= "1111";
			aluSel <= "111";
			selWrite <= "1111";
			
			writeSource <= '0';
			
			state := idle;
			stateDisp <= "00000000";
		
		-- Idle
		elsif(RISING_EDGE(clk) AND run = '1' AND state = idle) then
		
			writeSource <= '0';
		
			-- Move
			if(CODOP(NBITS-1 downto NBITS-4) = "0000") then
		
				writeSource <= '0';
				
				selA <= CODOP(NBITS-5 downto NBITS-8);
				selB <= CODOP(NBITS-9 downto NBITS-12);
				
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
				state := done;
				stateDisp <= "00000001";
				
			-- Move immediate
			elsif(CODOP(NBITS-1 downto NBITS-4) = "0001") then
		
				writeSource <= '0';
			
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
				state := moveI;
				stateDisp <= "00000010";
			
			-- ALU operation
			elsif(CODOP(NBITS-1) = '1') then
			
				writeSource <= '0';
			
				selA <= CODOP(NBITS-9 downto NBITS-12);
				selB <= CODOP(NBITS-13 downto NBITS-16);
				
				aluSel <= CODOP(NBITS-2 downto NBITS-4);
				
				selWrite <= CODOP(NBITS-5 downto NBITS-8);
			
				state := done;
				stateDisp <= "00000100";
			
			end if;
		
		elsif(RISING_EDGE(clk) AND run = '1' AND state = moveI) then
		
			writeSource <= '1';
			
			state := done;
			stateDisp <= "00000011";
		
		
		elsif(RISING_EDGE(clk) AND run = '1' AND state = done) then
		
			selA <= "1111";
			selB <= "1111";
			aluSel <= "111";
			selWrite <= "1111";
			
			writeSource <= '0';
			
			state := idle;
			stateDisp <= "00000000";
		
		end if;
	END PROCESS;
END ARCHITECTURE;	
			