(
s.waitForBoot {
	SynthDef(\unsortedEchoesFM, {
		arg out=0, freq=110, amp=0.035, gate=1, pan=0,
		modRatio=3, modIndex=1.2, drift=0.004,
		attack=6, release=12, echoMix=0.24, echoTime=0.38;
		var env, motion, pitchDrift, indexMotion, modulator, carrier, undertone;
		var signal, direct, reflection, reflectionDelay, reflectionPan;

		env = EnvGen.kr(Env.asr(attack, 1, release), gate, doneAction: 2);
		motion = LFNoise1.kr(0.08).range(0.7, 1.15);
		pitchDrift = LFNoise1.kr(0.035).range(drift.neg, drift);
		indexMotion = LFNoise1.kr(0.06).range(0.65, 1.25);

		modulator = SinOsc.ar(
			freq * modRatio * (1 + pitchDrift),
			mul: freq * modRatio * modIndex * motion * indexMotion
		);
		carrier = SinOsc.ar(freq * (1 + (pitchDrift * 0.4)) + modulator);
		undertone = SinOsc.ar(freq * 0.5 * (1 - pitchDrift)) * 0.16;

		signal = LeakDC.ar((carrier * 0.72) + undertone) * env * amp;
		signal = (signal * 1.5).tanh;

		direct = Pan2.ar(signal, pan.clip(-1, 1));
		reflectionDelay = (echoTime.clip(0.05, 0.8) * LFNoise1.kr(0.07).range(0.9, 1.1)).clip(0.05, 0.9);
		reflectionPan = (pan.neg + LFNoise1.kr(0.04).range(-0.18, 0.18)).clip(-1, 1);
		reflection = Pan2.ar(
			LPF.ar(DelayC.ar(signal, 1, reflectionDelay), (freq * 8).clip(500, 6000)),
			reflectionPan
		) * echoMix.clip(0, 0.7);

		Out.ar(out, direct + reflection);
	}).add;

	s.sync;

	~unsortedEchoesPattern = Pdef(\unsortedEchoes,
		Pbind(
			\instrument, \unsortedEchoesFM,
			\dur, 8,
			\scale, Scale.minor,
			\octave, 2,
			\degree, Pseq([
				[0, 2, 5, 9],
				[2, 5, 9, 12],
				[4, 7, 11, 14],
				[5, 9, 12, 16]
			], inf) + Prand([0, 0, 0, 1], inf),
			\pan, Pwhite(-0.8, 0.8, inf),
			\modRatio, Prand([1, 2, 3, 5], inf),
			\modIndex, Prand([0.5, 0.9, 1.3, 1.8], inf),
			\drift, Pwhite(0.001, 0.008, inf),
			\echoMix, Pwhite(0.16, 0.32, inf),
			\echoTime, Pwhite(0.24, 0.62, inf),
			\attack, 6,
			\release, 12,
			\legato, 1.2,
			\amp, 0.035
		)
	).play;
};
)

// Stop the pattern:
~unsortedEchoesPattern.stop;
