// Do not change the template
module digital_watch(
  input wire i_clk,
  input wire i_rst,
  input wire i_adjust_time,
  input wire [4:0] i_hour_new,
  input wire [5:0] i_minute_new,
  input wire [5:0] i_second_new, 
  input wire i_stopwatch_mode,
  input wire i_stopwatch_start,
  input wire i_stopwatch_stop,
  output logic [4:0] o_hour,
  output logic [5:0] o_minute,
  output logic [5:0] o_second
);
  logic go_stopwatch;
  logic [4:0] curr_hour, next_hour, curr_s_hour, next_s_hour, save_hour;
  logic [5:0] curr_minute, next_minute, curr_s_minute, next_s_minute, save_minute;
  logic [5:0] curr_second, next_second, curr_s_second, next_s_second, save_second;
  //only used for updates
  always_ff @(posedge i_clk or posedge i_rst or posedge i_stopwatch_mode) begin
      o_hour <= curr_hour;
      o_minute <= curr_minute;
  	  o_second <= curr_second;
  end
  
  //used for detecting inputs and process
  always_comb begin
    
    
    /*reset case*/
    if(i_rst)begin
      //reset normal clock times
      	next_hour = 5'd0;
      	next_minute = 6'd0;
      	next_second = 6'd0;
      	curr_hour = next_hour;
        curr_minute = next_minute;
        curr_second = next_second;
      //reset backup clock times
      	save_hour = 5'd0;
      	save_minute = 6'd0;
      	save_second = 6'd0;
      //reset stopwatch clock times
      	go_stopwatch = 1'b0; // stopwatch not running
      	next_s_hour = 5'b0;
      	next_s_minute = 6'b0;
      	next_s_second = 6'b0;
      	curr_s_hour = next_s_hour;
        curr_s_minute = next_s_minute;
        curr_s_second = next_s_second;
    end
    
    
    /*adjust time case*/
    else if (i_adjust_time) begin
      //current time still flows
      curr_hour = next_hour;
  	  curr_minute = next_minute;
  	  curr_second = next_second;
      //update to the next time
      next_hour = i_hour_new;
  	  next_minute = i_minute_new;
  	  next_second = i_second_new;
      	//update the backup clock times
      	save_hour = next_hour;
        save_minute = next_minute;
        save_second = next_second;
    end
    
    
    /*normal clock or stopwatch case*/
    else if (i_clk) begin 
      //stopwatch case
      if(i_stopwatch_mode)begin 
        //update to the current time
      	curr_hour = next_hour;
        curr_minute = next_minute;
        curr_second = next_second;
        //backup time still flows
        if(save_second == 6'd59)begin
        	save_second = 6'd0;
          	if(save_minute == 6'd59)begin
          		save_minute = 6'b0;
            	if(save_hour == 5'd23)begin
            	save_hour = 5'd0;
          		end
          		else begin
          			save_hour = save_hour + 5'd1;  
          		end
        	end
        	else begin
        	save_minute = save_minute + 6'd1;
        	end
      	end
      	else begin
      	save_second = save_second + 6'd1;
      	end
        //stopwatch time also flows
        curr_s_hour = next_s_hour;
        curr_s_minute = next_s_minute;
        curr_s_second = next_s_second;
        if(i_stopwatch_start) begin
          go_stopwatch=1'b1;
        end
        if(i_stopwatch_stop)begin
          go_stopwatch=1'b0;
        end
        //stopwatch time flows when running
        if(go_stopwatch)begin
          if(curr_s_second == 6'd59)begin
        	next_s_second = 6'd0;
            if(curr_s_minute == 6'd59)begin
          		next_s_minute = 6'b0;
              		if(curr_s_hour == 5'd23)begin
            		next_s_hour = 5'd0;
          	  		end
          			else begin
          			next_s_hour = curr_s_hour + 5'd1;  
          			end
        	end
        	else begin
        		next_s_minute = next_s_minute + 6'd1;
        	end
          end
          else begin
          	next_s_second = next_s_second + 6'd1;
          end
        end
        //update to the next time
        next_hour = next_s_hour;
        next_minute = next_s_minute;
        next_second = next_s_second;
      end
      
      //normal clock case
      else begin
        //update current time from next time first
      	curr_hour = next_hour;
        curr_minute = next_minute;
        curr_second = next_second;
        //and then load backup time
        next_hour = save_hour;
        next_minute = save_minute;
        next_second = save_second;
        //time flows
      if(curr_second == 6'd59)begin
        next_second = 6'd0;
        if(curr_minute == 6'd59)begin
          	next_minute = 6'b0;
          if(curr_hour == 5'd23)begin
            next_hour = 5'd0;
          end
          else begin
          	next_hour = next_hour + 5'd1;  
          end
        end
        else begin
        	next_minute = next_minute + 6'd1;
        end
      end
      else begin
      	next_second = next_second + 6'd1;
      end
        //save time
      	save_hour = next_hour;
        save_minute = next_minute;
        save_second = next_second;
      end
    end
  end 
  
  
endmodule