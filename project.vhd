library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity project_reti_logiche is
    Port (
        i_clk       : in STD_LOGIC;
        i_rst       : in STD_LOGIC;
        i_start     : in STD_LOGIC;
        i_data      : in STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_address   : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        o_done      : out STD_LOGIC;
        o_en        : out STD_LOGIC;
        o_we        : out STD_LOGIC;
        o_data      : out STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

    constant READ_ADDRESS_START     : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    constant WRITE_ADDRESS_START    : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000001111101000";  -- 1000
    constant UND_VECTOR             : STD_LOGIC_VECTOR(15 DOWNTO 0) := "UUUUUUUUUUUUUUUU";
    
    
    type state is (IDLE, READ_NUM_OF_WORDS, WAIT_MEM, READ_NTH_WORD, WAIT_MEM_2, ELABORATE, WRITE_1ST_RESULT, WRITE_2ND_RESULT, DONE);
    type conv_state is (S0, S1, S2, S3);
    
    
    signal current_state            : state := IDLE;
    
    signal current_conv_state       : conv_state := S0;
    signal next_conv_state          : conv_state := S0;
    signal saved_conv_state         : conv_state := S0;
    
    signal counter                  : INTEGER RANGE 0 TO 8;
    signal next_counter             : INTEGER RANGE 0 TO 8;
    
    signal input_address            : STD_LOGIC_VECTOR(15 DOWNTO 0) := READ_ADDRESS_START;
    signal output_address           : STD_LOGIC_VECTOR(15 DOWNTO 0) := WRITE_ADDRESS_START;
    signal temp_input_address       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal temp_output_address      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal result                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := UND_VECTOR;
    signal next_result              : STD_LOGIC_VECTOR(15 DOWNTO 0) := UND_VECTOR;
    signal saved_result             : STD_LOGIC_VECTOR(15 DOWNTO 0) := UND_VECTOR;
    
    signal num_of_words             : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal next_num_of_words        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal word                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal next_word                : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    signal save_result              : STD_LOGIC := '0';
    signal save_conv_state          : STD_LOGIC := '0';
    signal add_to_input_address     : STD_LOGIC := '0';
    signal add_to_output_address    : STD_LOGIC := '0';
    signal word_bit                 : STD_LOGIC;
    signal next_word_bit            : STD_LOGIC;
    
begin

    temp_input_address <= input_address + add_to_input_address;
    temp_output_address <= output_address + add_to_output_address;
    
    
    change_state : process(i_clk, i_start, i_rst) is
    begin
        if i_start = '0' or i_rst = '1' then
            current_state <= IDLE;
            input_address <= READ_ADDRESS_START;
            output_address <= WRITE_ADDRESS_START;
        elsif i_start = '1' then
            if falling_edge(i_clk) then
                input_address <= temp_input_address;
                output_address <= temp_output_address;
                counter <= next_counter;
                result <= next_result;
                current_conv_state <= next_conv_state;
                word <= next_word;
                word_bit <= next_word_bit;
                num_of_words <= next_num_of_words;
                case current_state is
                    when IDLE =>
                        current_state <= READ_NUM_OF_WORDS;
                    when READ_NUM_OF_WORDS =>
                        current_state <= WAIT_MEM;
                    when WAIT_MEM =>
                        if to_integer(unsigned(next_num_of_words)) = 0 then
                            current_state <= DONE;
                        else
                            current_state <= READ_NTH_WORD;
                        end if;
                    when READ_NTH_WORD =>
                        current_state <= WAIT_MEM_2;
                    when WAIT_MEM_2 =>
                        current_state <= ELABORATE;
                    when ELABORATE =>
                        if counter = 0 then
                            current_state <= WRITE_1ST_RESULT;
                        else
                            current_state <= ELABORATE;
                        end if;
                    when WRITE_1ST_RESULT =>
                        current_state <= WRITE_2ND_RESULT;
                    when WRITE_2ND_RESULT =>
                        if to_integer(unsigned(num_of_words)) > 0 then
                            current_state <= READ_NTH_WORD;
                        else
                            current_state <= DONE;
                        end if;
                    when DONE =>
                        current_state <= DONE;
                end case;
            end if;
        end if;
    end process change_state;
    
    
    state_settings : process(current_state, i_start) is
    begin
        add_to_input_address <= '0';
        add_to_output_address <= '0';
        o_done <= '0';
        o_en <= '0';
        o_we <= '0';
        o_address <= UND_VECTOR;
        o_data <= "00000000";
        if i_start = '1' then
            case current_state is
                when READ_NUM_OF_WORDS | READ_NTH_WORD =>
                    add_to_input_address <= '1';
                    o_en <= '1';
                    o_address <= input_address;
                when WRITE_1ST_RESULT =>
                    o_en <= '1';
                    o_we <= '1';
                    o_address <= output_address;
                    o_data <= saved_result(15 DOWNTO 8);
                    add_to_output_address <= '1';
                when WRITE_2ND_RESULT =>
                    o_en <= '1';
                    o_we <= '1';
                    o_address <= output_address;
                    o_data <= saved_result(7 DOWNTO 0);
                    add_to_output_address <= '1';
                when DONE =>
                    o_done <= '1';
                when others =>
            end case;
        end if;
    end process state_settings;
    
    
    memory : process(i_start, current_state, counter, word, num_of_words) is
    begin
        next_word <= "00000000";
        next_num_of_words <= num_of_words;
        if i_start = '1' then
            if current_state = WAIT_MEM then
                next_num_of_words <= i_data;
            elsif current_state = WAIT_MEM_2 then
                next_word(7 downto 1) <= i_data(6 downto 0);
                next_word(0) <= '0';
                next_num_of_words <= num_of_words - '1';
            elsif current_state = ELABORATE then
                if counter > 0 then
                    next_word(7 downto 1) <= word(6 downto 0);
                    next_word(0) <= '0';
                end if;
            end if;
        end if;
    end process memory;
    
    
    conv : process(i_start, i_rst, current_conv_state, counter, result, current_state, save_result, save_conv_state, word_bit) is
    begin
        next_conv_state <= S0;
        next_result <= UND_VECTOR;
        next_counter <= 0;
        save_result <= '0';
        save_conv_state <= '0';
        next_word_bit <= word(7);
        if i_start = '0' or i_rst = '1' then
            saved_conv_state <= S0;
        elsif i_start = '1' then
            if rising_edge(save_conv_state) then
                saved_conv_state <= current_conv_state;
            end if;
            if rising_edge(save_result) then
                saved_result <= result;
            end if;
            if current_state = WAIT_MEM_2 then
                next_counter <= 8;
                next_conv_state <= saved_conv_state;
                next_word_bit <= i_data(7);
            elsif current_state = ELABORATE then
                if counter > 0 then
                    next_counter <= counter - 1;
                    next_result(15 DOWNTO 2) <= result(13 DOWNTO 0);
                    case current_conv_state is
                        when S0 =>
                            if word_bit = '0' then
                                next_result(1 DOWNTO 0) <= "00";
                                next_conv_state <= S0;
                            else
                                next_result(1 DOWNTO 0) <= "11";
                                next_conv_state <= S1;
                            end if;
                        when S1 =>
                            if word_bit = '0' then
                                next_result(1 DOWNTO 0) <= "01";
                                next_conv_state <= S3;
                            else
                                next_result(1 DOWNTO 0) <= "10";
                                next_conv_state <= S2;
                            end if;
                        when S2 =>
                            if word_bit = '0' then
                                next_result(1 DOWNTO 0) <= "10";
                                next_conv_state <= S3;
                            else
                                next_result(1 DOWNTO 0) <= "01";
                                next_conv_state <= S2;
                            end if;
                        when S3 =>
                            if word_bit = '0' then
                                next_result(1 DOWNTO 0) <= "11";
                                next_conv_state <= S0;
                            else
                                next_result(1 DOWNTO 0) <= "00";
                                next_conv_state <= S1;
                            end if;
                    end case;
                else
                    save_result <= '1';
                    save_conv_state <= '1';
                end if;
            end if;
        end if;
    end process conv;
    
end Behavioral;