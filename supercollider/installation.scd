(
// Route to interface outputs 1-6; each event selects an output directly.
s = Server.local;
s.options.numOutputBusChannels_(6);
s.options.numInputBusChannels_(0);
s.options.sampleRate_(48000);
s.options.blockSize_(64);

// Add mono or stereo AI-voice recordings here. The patch reads channel 1.
~ueVoiceFiles = [];

s.waitForBoot {
	SynthDef(\bd808, {
		arg out=0, speaker=0, tone=56, decay=0.5, amp=1.5;
		var fenv, env, trienv, sig, sub, punch, pfenv;

		env = EnvGen.kr(Env.new([0.11, 1, 0], [0, decay], -225), doneAction: 2);
		trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, decay], -230));
		fenv = Env([tone * 7, tone * 1.35, tone], [0.05, 0.6], -14).kr;
		pfenv = Env([tone * 7, tone * 1.35, tone], [0.03, 0.6], -10).kr;
		sig = SinOsc.ar(fenv, pi/2) * env;
		sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
		punch = HPF.ar(SinOsc.ar(pfenv, pi/2) * env * 2, 350);
		sig = (sig + sub + punch) * 2.5;
		sig = Limiter.ar(sig, 0.5) * amp;
		Out.ar(out + speaker.clip(0, 5), sig);
	}).add;

	SynthDef(\sn808, {
		arg out=0, speaker=0, tone=340, tone2=189, snappy=0.3, decay=4.2,
		amp=1, amp2=1;
		var noiseEnv, atkEnv, sig, noise, osc1, osc2, sum;

		noiseEnv = EnvGen.kr(Env.perc(0.001, decay, 1, -115), doneAction: 2);
		atkEnv = EnvGen.kr(Env.perc(0.001, 0.8, curve: -95));
		noise = LPF.ar(HPF.ar(WhiteNoise.ar, 1800), 8850) * noiseEnv * snappy;
		osc1 = SinOsc.ar(tone2, pi/2) * 0.6;
		osc2 = SinOsc.ar(tone, pi/2) * 0.7;
		sum = (osc1 + osc2) * atkEnv * amp2;
		sig = HPF.ar((noise + sum) * amp * 2.5, 340);
		sig = Limiter.ar(sig, 0.5);
		Out.ar(out + speaker.clip(0, 5), sig);
	}).add;

	SynthDef(\hat808, {
		arg out=0, speaker=0, decay=0.42, amp=1;
		var sig, sighi, siglow, env, osc1, osc2, osc3, osc4, osc5, osc6;

		env = EnvGen.kr(Env.perc(0.005, decay, 1, -30), doneAction: 2);
		osc1 = LFPulse.ar(203.52);
		osc2 = LFPulse.ar(366.31);
		osc3 = LFPulse.ar(301.77);
		osc4 = LFPulse.ar(518.19);
		osc5 = LFPulse.ar(811.16);
		osc6 = LFPulse.ar(538.75);
		sighi = BHiPass.ar(BPF.ar(osc1 + osc2 + osc3 + osc4 + osc5 + osc6, 8900, 1), 9000);
		siglow = BHiPass.ar(BPF.ar(osc1 + osc2 + osc3 + osc4 + osc5 + osc6, 8900, 0.8), 9000, 0.3);
		sig = BPeakEQ.ar(siglow + sighi, 9700, 0.8, 0.7) * env * amp;
		sig = Limiter.ar(sig, 0.5);
		Out.ar(out + speaker.clip(0, 5), sig);
	}).add;

	SynthDef(\openhihat808, {
		arg out=0, speaker=0, decay=0.5, amp=1;
		var sig, env1, env2, osc1, osc2, osc3, osc4, osc5, osc6, sum;

		env1 = EnvGen.kr(Env.perc(0.1, decay, curve: -3), doneAction: 2);
		env2 = EnvGen.kr(Env.new([0, 1, 0], [0, decay * 5], curve: -150));
		osc1 = LFPulse.ar(203.52) * 0.6;
		osc2 = LFPulse.ar(366.31) * 0.6;
		osc3 = LFPulse.ar(301.77) * 0.6;
		osc4 = LFPulse.ar(518.19) * 0.6;
		osc5 = LFPulse.ar(811.16) * 0.6;
		osc6 = LFPulse.ar(538.75) * 0.6;
		sig = BLowShelf.ar(osc1 + osc2 + osc3 + osc4 + osc5 + osc6, 990, 2, -3);
		sig = BHiShelf.ar(BPeakEQ.ar(BPF.ar(sig, 7700), 7200, 0.5, 5), 9400, 1, 5);
		sig = BHiPass4.ar(sig, 8100, 0.7);
		sum = LPF.ar((sig * env1 * 0.6) + (sig * env2), 4000) * amp * 2;
		sum = Limiter.ar(sum, 0.5);
		Out.ar(out + speaker.clip(0, 5), sum);
	}).add;

	SynthDef(\cymbal808, {
		arg out=0, speaker=0, decay=2, tone=0.002, amp=1;
		var sig, sig1, sig2, sig2a, sig2b, sig3, env1, env2, env2b, env3;
		var osc1, osc2, osc3, osc4, osc5, osc6, sum;

		env1 = EnvGen.kr(Env.perc(0.3, decay, curve: -3), doneAction: 2);
		env2 = EnvGen.kr(Env.new([0, 0.6, 0], [0.1, decay * 0.7], -5));
		env2b = EnvGen.kr(Env.new([0, 0.3, 0], [0.1, decay * 20], -120));
		env3 = EnvGen.kr(Env.new([0, 1, 0], [0, decay * 5], curve: -150));
		osc1 = LFPulse.ar(203.52) * 0.6;
		osc2 = LFPulse.ar(366.31) * 0.6;
		osc3 = LFPulse.ar(301.77) * 0.6;
		osc4 = LFPulse.ar(518.19) * 0.6;
		osc5 = LFPulse.ar(811.16) * 0.6;
		osc6 = LFPulse.ar(538.75) * 0.6;
		sig = osc1 + osc2 + osc3 + osc4 + osc5 + osc6;
		sig1 = BHiPass.ar(LPF.ar(BPeakEQ.ar(BPF.ar(BLowShelf.ar(sig, 2000, 1, 5), 3000), 2400, 0.5, 5), 3000), 1550, 0.7);
		sig1 = BLowShelf.ar(sig1, 1000, 1, 0) * env1 * tone;
		sig2 = BHiShelf.ar(BHiPass4.ar(BPeakEQ.ar(BPF.ar(BLowShelf.ar(sig, 990, 2, -5), 7400), 7200, 0.5, 5), 6800, 0.7), 10000, 1, -4);
		sig2a = sig2 * env2 * 0.3;
		sig2b = sig2 * env2b * 0.6;
		sig3 = BHiPass4.ar(BPeakEQ.ar(BPF.ar(BLowShelf.ar(sig, 990, 2, -15), 6500), 7400, 0.35, 10), 10500, 0.8, 2) * env3;
		sum = LPF.ar(sig1 + sig2a + sig2b + sig3, 4000) * amp;
		sum = Limiter.ar(sum, 0.5);
		Out.ar(out + speaker.clip(0, 5), sum);
	}).add;

	SynthDef(\ueVoiceFragment, {
		arg out=0, speaker=0, reflectionSpeaker=1, buf=0, startPos=0,
		rate=1, segment=0.3, cutoff=2400, delay=0.32,
		reflectionAmp=0.25, amp=0.045;
		var source, env, voice, reflection;

		source = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, 1, startPos);
		env = EnvGen.kr(Env.linen(0.008, segment, 0.16), doneAction: 2);
		voice = BPF.ar(HPF.ar(source, 120), cutoff.clip(700, 6000), 0.3);
		voice = LeakDC.ar(voice) * env * amp;
		reflection = DelayC.ar(voice, 0.8, delay.clip(0.08, 0.72)) * reflectionAmp;

		Out.ar(out + speaker.clip(0, 5), voice);
		Out.ar(out + reflectionSpeaker.clip(0, 5), reflection);
	}).add;

	s.sync;

	~ueVoiceBuffers = [];
	if(~ueVoiceFiles.isEmpty) {
		"No AI voice files configured; the five drum patterns will still play.".warn;
	} {
		~ueVoiceBuffers = ~ueVoiceFiles.c12ollect { |path|
			Buffer.readChannel(s, path, channels: [0]);
		};
		s.sync;
	};

	~ueStart = {
		Pdef(\ue808, Pbind(
			\instrument, \bd808,
			\tone, Prand([38, 42, 46, 55], inf),
			\decay, Pwhite(0.35, 0.9, inf),
			\amp, Pwhite(1.2, 1.9, inf),
			\type, Pwrand([\note, \rest], [0.88, 0.12], inf),
			\speaker, Prand((0..5), inf),
			\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25], inf)
		)).play;

		Pdef(\ueSnare, Pbind(
			\instrument, \sn808,
			\tone, Prand([290, 340, 410, 470], inf),
			\tone2, Prand([150, 189, 225], inf),
			\decay, Pwhite(0.7, 1.8, inf),
			\snappy, Pwhite(0.18, 0.42, inf),
			\amp, Pwhite(0.8, 1.2, inf),
			\amp2, Pwhite(0.7, 1.2, inf),
			\type, Pwrand([\note, \rest], [0.62, 0.38], inf),
			\speaker, Prand((0..5), inf),
			\dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.35, 0.1], inf)
		)).play;

		Pdef(\ueHat, Pbind(
			\instrument, \hat808,
			\decay, Pwhite(0.12, 0.42, inf),
			\amp, Pwhite(0.7, 1.1, inf),
			\type, Pwrand([\note, \rest], [0.9, 0.1], inf),
			\speaker, Prand((0..5), inf),
			\dur, Pwrand([0.125, 0.25, 0.375], [0.62, 0.3, 0.08], inf)
		)).play;

		Pdef(\ueOpenHat, Pbind(
			\instrument, \openhihat808,
			\decay, Pwhite(0.28, 0.8, inf),
			\amp, Pwhite(0.65, 1.0, inf),
			\type, Pwrand([\note, \rest], [0.36, 0.64], inf),
			\speaker, Prand((0..5), inf),
			\dur, Pwrand([0.25, 0.5, 0.75], [0.25, 0.5, 0.25], inf)
		)).play;

		Pdef(\ueCymbal, Pbind(
			\instrument, \cymbal808,
			\decay, Pwhite(1.4, 3.6, inf),
			\tone, Pwhite(0.001, 0.004, inf),
			\amp, Pwhite(0.65, 1.0, inf),
			\type, Pwrand([\note, \rest], [0.55, 0.45], inf),
			\speaker, Prand((0..5), inf),
			\dur, Pwrand([0.5, 0.75, 1.0, 1.5], [0.2, 0.3, 0.35, 0.15], inf)
		)).play;

		if(~ueVoiceBuffers.notEmpty) {
			Pdef(\ueVoices, Pbind(
				\instrument, \ueVoiceFragment,
				\buf, Pfunc { ~ueVoiceBuffers.choose },
				\startPos, Pfunc { |event|
					(event[\buf].numFrames * 0.65.rand).asInteger;
				},
				\rate, Prand([0.68, 0.82, 1.0, 1.17, 1.36], inf),
				\segment, Pwhite(0.18, 0.65, inf),
				\cutoff, Pwhite(900, 4800, inf),
				\delay, Pwhite(0.16, 0.78, inf),
				\reflectionAmp, Pwhite(0.16, 0.48, inf),
				\amp, Pwhite(0.025, 0.055, inf),
				\type, Pwrand([\note, \rest], [0.58, 0.42], inf),
				\speaker, Prand((0..5), inf),
				\reflectionSpeaker, Pfunc { |event|
					(event[\speaker] + rrand(1, 5)) % 6;
				},
				\dur, Pwrand([0.125, 0.25, 0.375, 0.5], [0.24, 0.4, 0.24, 0.12], inf)
			)).play;
		};
	};

	~ueStop = {
		[\ue808, \ueSnare, \ueHat, \ueOpenHat, \ueCymbal, \ueVoices].do { |name|
			Pdef(name).stop;
		};
	};

	~ueStart.();
};
)

s.meter;