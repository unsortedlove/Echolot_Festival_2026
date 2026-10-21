(
s.waitForBoot {
	SynthDef(\spectralDrone, {
		arg out=0, freq=220, amp=0.07, pan=0, splay=0.9, gate=1,
		attack=8, release=18,
		ratio1=1, ratio2=3, ratio3=1, ratio4=3, ratio5=5, ratio6=1,
		index2=1, index3=1, index4=1, index5=1;
		var env, motion, drift, mod2, mod3, mod4, mod5;
		var partial1, partial2, partial3, partial4, partial5, low, veil, signal;
		var direct, reflection, reflectionDelay, reflectionPan;

		env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
		motion = LFNoise1.kr(0.07).range(0.35, 1);
		drift = LFNoise1.kr(0.035).range(-0.003, 0.003);

		mod2 = SinOsc.ar(freq * ratio2 * (1 + drift), 0, freq * ratio2 * index2 * motion * 0.45);
		mod3 = SinOsc.ar(freq * ratio3 * (1 - drift), 0, freq * ratio3 * index3 * motion * 0.35);
		mod4 = SinOsc.ar(freq * ratio4 * (1 + (drift * 1.7)), 0, freq * ratio4 * index4 * motion * 0.3);
		mod5 = SinOsc.ar(freq * ratio5 * (1 - (drift * 1.3)), 0, freq * ratio5 * index5 * motion * 0.25);

		partial1 = SinOsc.ar(freq * ratio1 * (1 + drift) + mod2) * 0.32;
		partial2 = SinOsc.ar(freq * ratio3 * 1.006 + mod3) * 0.24;
		partial3 = SinOsc.ar(freq * ratio4 * (1 - drift) + mod4) * 0.2;
		partial4 = SinOsc.ar(freq * ratio5 * 0.997 + mod5) * 0.16;
		partial5 = SinOsc.ar(freq * ratio6 * (1 + (drift * 2)) + mod2 * 0.5) * 0.12;
		low = SinOsc.ar(freq * 0.5 * (1 - drift)) * 0.12;
		veil = BPF.ar(WhiteNoise.ar(0.018), (freq * 4).clip(180, 8000), 0.18);

		signal = (partial1 + partial2 + partial3 + partial4 + partial5 + low + veil) * env * amp;
		signal = (signal * 1.4).tanh;
		signal = Limiter.ar(signal, 0.7);

		direct = Pan2.ar(signal, (pan * splay).clip(-1, 1));
		reflectionDelay = LFNoise1.kr(0.025).range(0.23, 0.61);
		reflectionPan = (pan.neg * splay).clip(-1, 1);
		reflection = Pan2.ar(
			DelayC.ar(signal, 0.7, reflectionDelay) * 0.22,
			reflectionPan
		);
		Out.ar(out, direct + reflection);
	}).add;

	s.sync;

	~pat = Pdef(\a,
		Pbind(
			\instrument, \spectralDrone,
			\dur, 10,
			\scale, Scale.minor,
			\octave, 2,
			\degree, Pseq([
				[0, 2, 5, 9],
				[2, 5, 9, 12],
				[4, 7, 11, 14],
				[5, 9, 12, 16]
			], inf) + Prand([0, 0, 0, 1], inf),
			\splay, 0.9,
			\pan, Pwhite(-1.0, 1.0, inf),
			\ratio1, Prand([1, 3, 5], inf),
			\ratio2, Prand([1, 3, 5], inf),
			\ratio3, Prand([1, 3, 5], inf),
			\ratio4, Prand([1, 3, 5], inf),
			\ratio5, Prand([1, 3, 5], inf),
			\ratio6, Prand([1, 3, 5], inf),
			\index2, Prand([0.4, 0.8, 1.2], inf),
			\index3, Prand([0.4, 0.8, 1.2], inf),
			\index4, Prand([0.4, 0.8, 1.2], inf),
			\index5, Prand([0.4, 0.8, 1.2], inf),
			\attack, 8,
			\release, 18,
			\legato, 1.2,
			\amp, 0.05
		)
	).play;
};
)

// Stop the pattern:
~pat.stop;
