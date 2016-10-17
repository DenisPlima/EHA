--Copyright (C) 2016 Siavoosh Payandeh Azad

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;

entity PACKETIZER_LV is
    generic (
        DATA_WIDTH: integer := 11;
        current_address : integer := 0;
        SHMU_address : integer := 0
    );
    port (
        reset, clk: in std_logic;
         
        faulty_packet_N, faulty_packet_E, faulty_packet_W, faulty_packet_S, faulty_packet_L: in  std_logic;
        healthy_packet_N, healthy_packet_E, healthy_packet_W, healthy_packet_S, healthy_packet_L: in  std_logic;

        credit_in_LV: in std_logic;
        valid_out_LV : out std_logic;
        TX_LV: out std_logic_vector (DATA_WIDTH-1 downto 0)
    );
end;

architecture behavior of PACKETIZER_LV is

 
 
 signal read_pointer, read_pointer_in,  write_pointer, write_pointer_in: std_logic_vector(2 downto 0);

 signal credit_counter_in, credit_counter_out: std_logic_vector(1 downto 0);
 
 type STATE_TYPE IS (IDLE, HEADER_FLIT, BODY_FLIT, TAIL_FLIT);
 signal state, state_in   : STATE_TYPE := IDLE;

 signal FIFO_MEM_1, FIFO_MEM_1_in : std_logic_vector(9 downto 0);
 signal FIFO_MEM_2, FIFO_MEM_2_in : std_logic_vector(9 downto 0);
 signal FIFO_MEM_3, FIFO_MEM_3_in : std_logic_vector(9 downto 0);

 signal FIFO_Data_out: std_logic_vector(9 downto 0);

 signal grant, all_input_signals: std_logic;

begin

process (clk, reset)begin
        if reset = '0' then
             FIFO_MEM_1 <= (others=>'0');
             FIFO_MEM_2 <= (others=>'0');
             FIFO_MEM_3 <= (others=>'0');
             read_pointer <= "001";
             write_pointer <= "001";
             credit_counter_out<="01";
             state<=IDLE;
        elsif clk'event and clk = '1' then
            if all_input_signals = '1' then
                FIFO_MEM_1 <= FIFO_MEM_1_in;
                FIFO_MEM_2 <= FIFO_MEM_2_in;
                FIFO_MEM_3 <= FIFO_MEM_3_in;
            end if;
            read_pointer <=  read_pointer_in;
            write_pointer <=  write_pointer_in;
            credit_counter_out <=  credit_counter_in;
            state <= state_in;
        end if;
end process;

all_input_signals <= faulty_packet_N or faulty_packet_E or faulty_packet_W or faulty_packet_S or faulty_packet_L or healthy_packet_N or healthy_packet_E or healthy_packet_W or healthy_packet_S or healthy_packet_L;
--all_input_signals <= faulty_packet_N or faulty_packet_E or faulty_packet_W or faulty_packet_S or faulty_packet_L or healthy_packet_N;

process(all_input_signals)begin
    if  all_input_signals = '1' then
        write_pointer_in <= write_pointer(0) & write_pointer(2 downto 1); 
    else
        write_pointer_in <= write_pointer; 
    end if;
end process;

process(faulty_packet_N, faulty_packet_E, faulty_packet_W, faulty_packet_S, faulty_packet_L, healthy_packet_N, healthy_packet_E, healthy_packet_W, healthy_packet_S, healthy_packet_L, write_pointer, FIFO_MEM_1, FIFO_MEM_2, FIFO_MEM_3)begin
      case( write_pointer ) is
          when "001" => FIFO_MEM_1_in <= faulty_packet_N & faulty_packet_E & faulty_packet_W & faulty_packet_S & faulty_packet_L & healthy_packet_N & healthy_packet_E & healthy_packet_W & healthy_packet_S & healthy_packet_L; FIFO_MEM_2_in <= FIFO_MEM_2; FIFO_MEM_3_in <= FIFO_MEM_3; 
          when "010" => FIFO_MEM_1_in <= FIFO_MEM_1; FIFO_MEM_2_in <= faulty_packet_N & faulty_packet_E & faulty_packet_W & faulty_packet_S & faulty_packet_L & healthy_packet_N & healthy_packet_E & healthy_packet_W & healthy_packet_S & healthy_packet_L; FIFO_MEM_3_in <= FIFO_MEM_3; 
          when "100" => FIFO_MEM_1_in <= FIFO_MEM_1; FIFO_MEM_2_in <= FIFO_MEM_2; FIFO_MEM_3_in <= faulty_packet_N & faulty_packet_E & faulty_packet_W & faulty_packet_S & faulty_packet_L & healthy_packet_N & healthy_packet_E & healthy_packet_W & healthy_packet_S & healthy_packet_L; 
          when others => FIFO_MEM_1_in <= FIFO_MEM_1; FIFO_MEM_2_in <= FIFO_MEM_2; FIFO_MEM_3_in <= FIFO_MEM_3;  
      end case ;
end process;

process(read_pointer, FIFO_MEM_1, FIFO_MEM_2, FIFO_MEM_3) begin
 case( read_pointer ) is
        when "001" => FIFO_Data_out <= FIFO_MEM_1;
        when "010" => FIFO_Data_out <= FIFO_MEM_2;
        when "100" => FIFO_Data_out <= FIFO_MEM_3;
        when others => FIFO_Data_out <= FIFO_MEM_1; 
end case ;
end process;

process (credit_in_LV, credit_counter_out, grant)begin
    credit_counter_in <= credit_counter_out;
    if credit_in_LV = '1' and credit_counter_out < 1 then 
        credit_counter_in <= credit_counter_out + 1;
    elsif grant = '1' then
        credit_counter_in <= credit_counter_out - 1;
    end if;
end process;


process(all_input_signals, state, read_pointer, credit_counter_out)
    begin
        TX_LV <= (others => '0');
        grant<= '0';
        case(state) is
        
            when IDLE =>
                if all_input_signals= '1' then
                    state_in <= HEADER_FLIT;
                else
                    state_in <= IDLE;
                end if;
                read_pointer_in <=  read_pointer;
            when HEADER_FLIT =>
                if credit_counter_out /= "00" then
                    grant <= '1';
                    TX_LV <= std_logic_vector(to_unsigned(current_address, 4))  & std_logic_vector(to_unsigned(SHMU_address, 4)) &  "001";
                    state_in <= BODY_FLIT;
                else
                    state_in <= HEADER_FLIT;
                end if;
                read_pointer_in <=  read_pointer(0) & read_pointer(2 downto 1);    
            when BODY_FLIT =>
                if credit_counter_out /= "00" then
                    grant <= '1';
                    TX_LV <= FIFO_Data_out(7 downto 0) &  "010";
                    state_in <= TAIL_FLIT;
                else
                    state_in <= BODY_FLIT;
                end if;

            when TAIL_FLIT =>
                if credit_counter_out /= "00" then
                    grant <= '1';
                    TX_LV <= "000000" & FIFO_Data_out(9 downto 8) &  "100";
                    state_in <= IDLE;
                else
                    state_in <= TAIL_FLIT;
                end if;
            when others =>
                state_in <= IDLE;
        end case ;

end procesS;
 
valid_out_LV <= grant;
end;