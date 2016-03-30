LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY CPU IS
GENERIC(NBITS : positive := 16);
PORT (
	clock, Run, nReset: IN std_logic;
	Din: IN std_logic_vector(NBITS-1 downto 0);
	Done, idle : OUT std_logic;
	Result : OUT std_logic_vector(NBITS-1 downto 0);
	countClock : OUT std_logic_vector(7 downto 0);
	CODOPout : OUT std_logic_vector(3 downto 0)
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

COMPONENT ONE_HOT_8 IS
	PORT (
		sel : in STD_LOGIC_VECTOR(2 downto 0);
		s : out STD_LOGIC_VECTOR(7 downto 0)
	);
END COMPONENT ONE_HOT_8;

COMPONENT ControlUnit IS
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
SIGNAL sel_write : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL alu_output : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL overflow : STD_LOGIC;

SIGNAL CODOP : STD_LOGIC_VECTOR(NBITS-1 downto 0);
SIGNAL saveCODOP : STD_LOGIC := '1';

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
															 sel => sel_a(2 downto 0), s => a);

	muxB : MUX_8_N GENERIC MAP(NBITS) PORT MAP(a => reg_output(0), b => reg_output(1), c => reg_output(2), d => reg_output(4),
															 e => reg_output(4), f => reg_output(5), g => reg_output(6), h => reg_output(7),
															 sel => sel_b(2 downto 0), s => b);

	alu : ALU_N GENERIC MAP(NBITS) PORT MAP(a => a, b => b,
														 sel => sel_alu,
														 s => alu_output, c_out => overflow);

	dataSelector : MUX_2_N GENERIC MAP(NBITS) PORT MAP(a => alu_output, b => Din,
																		sel => write_origin, s => write_data);
	Result <= write_data;

	codopRegister : REGISTER_N GENERIC MAP(NBITS) PORT MAP (d => Din, en => saveCODOP, clk => clock, r => nReset, q => CODOP);
	
	FSM : ControlUnit GENERIC MAP(NBITS) PORT MAP(run => Run, reset => nReset, CODOP => CODOP, clk => clock,
																 aluSel => sel_alu, selA => sel_a, selB => sel_b, DoneSignal => Done, writeSource => write_origin,
																 idleSignal => idle, selWrite => sel_write, countClock => countClock,
																 CODOPout => CODOPout, CODOPSave => saveCODOP);

	--with sel_write select
	--	write_origin <=
	--	'1' when "1111",
	--	'0' when others;
	
	write_hot : ONE_HOT_8 PORT MAP(sel => sel_write(2 downto 0), s => write_in_reg(7 downto 0));
END Behavior;
