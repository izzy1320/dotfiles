starship init fish | source

function fish_greeting
	fastfetch
end

if status is-login
	if test (tty) = /dev/tty1
		exec sway --unsupported-gpu
	end
end
