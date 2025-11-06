architecture Mealy of newMealy is
	type state_type is (A, B, C, D);
	signal presentState, nextState : state_type;
	
	-- We need a signal to check if a transition will happen
	signal s_transition_imminent : std_logic; 
begin

	-- 1. Combinational process to determine next state and transition flag
	process(presentState, i_x, SSCS) -- Added SSCS to sensitivity list
	begin
        -- Default to no transition
        s_transition_imminent <= '0';
        nextState <= presentState; -- Default to staying in the current state

		case presentState is
			when A => 
                if i_x = '1' and SSCS = '1' then
					nextState <= B;
                    s_transition_imminent <= '1';
				end if;
			when B => 
                if i_x = '1' then
					nextState <= C;
                    s_transition_imminent <= '1';
				end if;
			when C => 
                if i_x = '1' then
					nextState <= D;
                    s_transition_imminent <= '1';
				end if;
			when D => 
                if i_x = '1' then
					nextState <= A;
                    s_transition_imminent <= '1';
				end if;
		end case;
	end process;

	-- 2. Sequential process for state update and pulse generation
	process (i_clk, i_resetb)
	begin
		if (i_resetb = '0') then
			presentState <= A;
			o_start_pulse <= '0'; -- Reset pulse low
		elsif (i_clk'EVENT and i_clk='1') then
			presentState <= nextState;
			
			-- Generate the pulse on the clock edge when transition happens
			if s_transition_imminent = '1' then
				o_start_pulse <= '1';
			else
				o_start_pulse <= '0';
			end if;
		end if;
	end process;
	
	-- 3. Combinational process to update the system outputs (Mealy)
	-- ... (Keep your existing output process here, connecting i_x to o_MSTL/o_SSTL)
	-- NOTE: You should still review the Mealy outputs as they are unusual for traffic lights.
    -- I am keeping them as you wrote them for now.
	process(presentState,i_x)
	begin
        -- Must assign defaults if i_x is not covered, though case covers all states.
        o_state <= (others => '0'); 
        o_MSTL <= (others => '0');
        o_SSTL <= (others => '0');
        
		case presentState is
			when A => if i_x = '0' then
							o_MSTL <= "100";
							o_SSTL <= "001";
						else
							o_MSTL <= "010";
							o_SSTL <= "001";
						end if;
						o_state <= "00";
			when B => if i_x = '0' then
							o_MSTL <= "010";
							o_SSTL <= "001";
						else
							o_MSTL <= "001";
							o_SSTL <= "100";
						end if;
						o_state <= "01";
			when C => if i_x = '0' then
							o_MSTL <= "001";
							o_SSTL <= "100";
						else
							o_MSTL <= "001";
							o_SSTL <= "010";
						end if;
						o_state <= "10";
			when D => if i_x = '0' then
							o_MSTL <= "001";
							o_SSTL <= "010";
						else
							o_MSTL <= "100";
							o_SSTL <= "001";
						end if;
						o_state <= "11";
		end case;
	end process;
end Mealy;