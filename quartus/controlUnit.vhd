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
	DoneSignal : OUT std_logic;
	clk: IN std_logic
);
END ControlUnit;

ARCHITECTURE Behavior OF ControlUnit IS
TYPE state_t IS (idle, init, move, moveImmediate, moveImmediate2, operation, done);
VARIABLE state : state_t;
BEGIN
	PROCESS(clk)
	BEGIN
		--reset
		if(reset = '0') then state := init;

		--init
		elsif(clk = '1' AND state = init) then
			CODOPSave <= '1';
			selA <= "1111"; -- A from In
			selB <= "1111"; -- B from In
			aluSel <= "111"; -- empty operation from alu
			selWrite <= "1111"; -- no write
			DoneSignal <= '0';

			state := idle;

		--idle
		elsif(clk = '1'  AND run = '1' AND state = idle) then
			--do things
			DoneSignal <= '0';
			--store CODOP
			CODOPSave <= '0';

			if(CODOP(NBITS-1 downto NBITS-4) = "0000") then
				state := move;
			elsif(CODOP(NBITS-1 downto NBITS-4) = "0001") then
				state := moveImmediate;
			elsif(CODOP(NBITS-1) = '1') then
				state := operation;
			end if;

		--move
		elsif(clk = '1'  AND run = '1' AND state = move) then
			selA <= CODOP(NBITS-9 downto NBITS-12);
			selB <= CODOP(NBITS-9 downto NBITS-12);
			aluSel <= "100"; -- AND or OR
			selWrite <= CODOP(NBITS-5 downto NBITS-8);

			state := done;

		--moveImmediate1: wait clock redirect
		elsif(clk = '1'  AND run = '1' AND state = moveImmediate) then
			selA <= "1111";
			selA <= "1111";
			aluSel <= "100"; -- AND or OR
			selWrite <= CODOP(NBITS-5 downto NBITS-8);

			state := moveImmediate2;

		--moveImmediate2: memorize
		elsif(clk = '1'  AND run = '1' AND state = moveImmediate2) then
			state := done;

		--operation
		elsif(clk = '1'  AND run = '1' AND state = operation) then
			selA <= CODOP(NBITS-5 downto NBITS-8);
			selB <= CODOP(NBITS-9 downto NBITS-12);
			aluSel <= CODOP(NBITS-2 downto NBITS-4);
			selWrite <= CODOP(NBITS-5 downto NBITS-8);

			state := done;

		--DONE
		elsif(clk = '1'  AND run = '1' AND state = done) then
			CODOPSave <= '1';
			selA <= "1111";
			selB <= "1111";
			aluSel <= "111";
			selWrite <= "1111";
			DoneSignal <= '1';

			state := idle;

		end if;
	END PROCESS;
END Behavior;





LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY CPU IS
GENERIC(NBITS : positive := 16);
PORT (
	clock, Run, nReset: IN std_logic;
	Din: IN std_logic_vector(NBITS-1 downto 0);
	Done : OUT std_logic
);
END CPU;

ARCHITECTURE Behavior OF CPU IS

COMPONENT REGISTER_N IS
	GENERIC (SIZE_REG: positive := 8);
	PORT (
		d : IN std_logic_vector(SIZE_REG-1 downto 0);
		en, clk, r : IN std_logic; -- enable clock, clock, reset
		q : OUT std_logic_vector(SIZE_REG-1 downto 0)
	);
END COMPONENT REGISTER_N;

COMPONENT MUX_8_N IS
GENERIC( SIZE_MUX_8 : positive := 8);
PORT (
	a, b, c, d, e, f, g, h : in STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0) := (others => '0');
	sel : in STD_LOGIC_VECTOR(2 downto 0);
	s : out STD_LOGIC_VECTOR(SIZE_MUX_8-1 downto 0)
);
END COMPONENT MUX_8_N;

COMPONENT ALU_N IS
GENERIC( SIZE_ALU : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
	sel : in STD_LOGIC_VECTOR(2 downto 0);

	s : out STD_LOGIC_VECTOR(SIZE_ALU-1 downto 0);
	c_out : out STD_LOGIC
);
END COMPONENT ALU_N;

COMPONENT MUX_2_N IS
GENERIC( NB_BITS : positive := 8);
PORT (
	a, b : in STD_LOGIC_VECTOR(NB_BITS-1 downto 0) := (others => '0');
	sel : in STD_LOGIC;
	s : out STD_LOGIC_VECTOR(NB_BITS-1 downto 0)
);
END COMPONENT MUX_2_N;

COMPONENT ControlUnit IS
GENERIC(NBITS : positive := 16);
PORT (
	run, reset: IN std_logic;
	CODOP: IN std_logic_vector(NBITS-1 downto 0);
	CODOPSave : OUT std_logic;
	selA, selB : OUT std_logic_vector(3 downto 0);
	aluSel : OUT std_logic_vector(2 downto 0);
	selWrite : OUT std_logic_vector(3 downto 0);
	DoneSignal : OUT std_logic;
	clk: IN std_logic
);
END COMPONENT ControlUnit;

TYPE data_array IS ARRAY(0 to 7) OF STD_LOGIC_VECTOR(NBITS-1 downto 0);

SIGNAL write_in_reg : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL write_data : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL reg_output : data_array;

SIGNAL a : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL sel_a : std_logic_vector(3 downto 0);
SIGNAL sel_b : std_logic_vector(3 downto 0);
SIGNAL b : STD_LOGIC_VECTOR(NBITS-1 downto 0);

SIGNAL sel_alu : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL alu_output : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL overflow : STD_LOGIC;

SIGNAL CODOP : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL saveCODOP : STD_LOGIC;

SIGNAL write_origin : STD_LOGIC;

BEGIN
	reg0 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(0), en => write_in_reg(0), clk => clock, r => nReset);
	reg1 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(1), en => write_in_reg(1), clk => clock, r => nReset);
	reg2 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(2), en => write_in_reg(2), clk => clock, r => nReset);
	reg3 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(3), en => write_in_reg(3), clk => clock, r => nReset);
	reg4 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(4), en => write_in_reg(4), clk => clock, r => nReset);
	reg5 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(5), en => write_in_reg(5), clk => clock, r => nReset);
	reg6 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(6), en => write_in_reg(6), clk => clock, r => nReset);
	reg7 : REGISTER_N GENERIC MAP(NBITS) PORT MAP(d => write_data, q => reg_output(7), en => write_in_reg(7), clk => clock, r => nReset);

	muxA : MUX_8_N GENERIC MAP(NBITS) PORT MAP(a => reg_output(0), b => reg_output(1), c => reg_output(2), d => reg_output(4),
															 e => reg_output(4), f => reg_output(5), g => reg_output(6), h => reg_output(7),
															 sel => sel_a, s => a);

	muxB : MUX_8_N GENERIC MAP(NBITS) PORT MAP(a => reg_output(0), b => reg_output(1), c => reg_output(2), d => reg_output(4),
															 e => reg_output(4), f => reg_output(5), g => reg_output(6), h => reg_output(7),
															 sel => sel_b, s => b);

	alu : ALU_N GENERIC MAP(NBITS) PORT MAP(a => a, b => b,
														 sel => sel_alu,
														 s => alu_output, c_out => overflow);

	dataSelector : MUX_2_N GENERIC MAP(NBITS) PORT MAP(a => alu_output, b => Din,
																		sel => write_origin, s => write_data);

	codopRegister : REGISTER_N GENERIC MAP(NBITS) PORT MAP (d => Din, en => saveCODOP, clk => clock, r => nReset, q => CODOP);
	FSM : ControlUnit GENERIC MAP(NBITS) PORT MAP(run => Run, reset => nReset, CODOP => CODOP, clk => clock,
																			aluSel => sel_alu, selA => sel_a, selB => sel_b, DoneSignal => Done);

END Behavior;
