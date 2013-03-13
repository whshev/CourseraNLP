h = {}
STDIN.each do |line|
	l = line.split
	if l.length == 2
		h.key?(l[0]) ? h[l[0]] += 1 : h[l[0]] = 1
	end
end
File.readlines("gene.train.bak").each do |line|
	l = line.split
	if l.length == 2
		if (h[l[0]] < 5)
			if l[0][/\d/] != nil
				print "_NUMERIC_ #{l[1]}\n"
			elsif (l[0] =~ /^[A-Z]+$/) != nil
				print "_ALLCAPITALS_ #{l[1]}\n"
			elsif (l[0] =~ /[A-Z]$/) != nil
				print "_ENDCAPITALS_ #{l[1]}\n"
			else
				print "_RARE_ #{l[1]}\n"
			end			
		else
			print line
		end
	else
		print line
	end
end
