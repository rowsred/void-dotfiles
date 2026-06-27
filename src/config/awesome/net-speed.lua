local wibox = require("wibox")
local awful = require("awful")

-- Create the baseline textbox widget
local net_widget = wibox.widget.textbox()
net_widget:set_align("center")

-- Global variables tracking previous total bytes processed
local prev_rx = 0
local prev_tx = 0

-- Command that automatically finds your active route's network interface
local cmd =
	[[sh -c "interface=\$(ip route | grep default | awk '{print \$5}' | head -n1); if [ -n \"\$interface\" ]; then cat /proc/net/dev | grep \"\$interface\"; fi"]]

awful.widget.watch(cmd, 1, function(widget, stdout)
	-- Parse out received (rx) and transmitted (tx) columns
	local rx, tx = stdout:match("%s*(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")

	if rx and tx then
		rx = tonumber(rx)
		tx = tonumber(tx)

		if prev_rx > 0 and prev_tx > 0 then
			-- Calculate delta difference per second (divided by 1024 for KB)
			local speed_rx = (rx - prev_rx) / 1024
			local speed_tx = (tx - prev_tx) / 1024

			-- Format values nicely to KB/s or MB/s dynamically
			local rx_str = speed_rx > 1024 and string.format("%.1f MB/s", speed_rx / 1024)
				or string.format("%.0f KB/s", speed_rx)
			local tx_str = speed_tx > 1024 and string.format("%.1f MB/s", speed_tx / 1024)
				or string.format("%.0f KB/s", speed_tx)

			-- Update the text inside the wibar widget using Pango markup coloring
			widget:set_markup(
				"<span foreground='#00FF00'>↓</span> "
					.. rx_str
					.. " <span foreground='#FF0000'>↑</span> "
					.. tx_str
			)
		else
			widget:set_text("...")
		end

		prev_rx = rx
		prev_tx = tx
	else
		widget:set_text("Net: Down")
	end
end, net_widget)

return net_widget
