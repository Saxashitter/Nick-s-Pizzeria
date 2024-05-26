.PHONY: both, ntopp

both:
	node PaK3/main.js ntopp/ build/ntopp.pk3
	node PaK3/main.js ptv3/ build/ptv3.pk3
pt:
	node PaK3/main.js ptv3/ build/ptv3.pk3
ntopp:
	node PaK3/main.js ntopp/ build/ntopp.pk3