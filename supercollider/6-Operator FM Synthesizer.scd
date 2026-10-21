////////////////////// \unsorted echolot festival

////////////////////// \system
(
s = Server.local;
ServerOptions.devices;
s.options.outDevice_("Babyface Pro (72994168)");
s.options.numOutputBusChannels_(12);
s.options.inDevice_("Babyface Pro (72994168)");
s.options.numInputBusChannels_(8);
s.options.sampleRate_(48000);
s.options.blockSize = 64;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 128;
s.scope;
s.meter;
s.freeAll;
s.waitForBoot({
})
)

////////////////////// \important evaluate this buffer for a single sample feedback possibility
////////////////////// \free buffers if you have buffers evaluated: Buffer.freeAll;
b = Buffer.alloc(s, 1);

////////////////////// \system
(
SynthDef(\fm,{ arg amp=0.8,freq=20,splay=0.4, index2, index3, index4, index5, index6=10, ratio1=1,ratio2=2,ratio3=3,ratio4=3,ratio5=6,ratio6=2,env1att=0.007,env1rel=3, env2att=0.007,env2rel=3, env3att=0.007,env3rel=3;
	var osc1, osc2, osc3,osc4,osc5,osc6, env1, env2,env3,env4,env5,env6,env7,env8,env9,sound, osc2fb;
//modulation envelope
	env2=EnvGen.ar(Env.perc(env2att,env2rel),doneAction:0);


//osc block 1
	osc2fb = Dbufrd(b); // read from buffer
	osc2fb = SinOsc.ar(freq + (ratio2*freq * env2* Duty.ar(SampleDur.ir,0,osc2fb) ), mul:freq*ratio2*env2*index2);
    osc2 = Dbufwr(osc2fb, b); // write to buffer
    osc2 = Duty.ar(SampleDur.ir, 0, osc2);
	osc1=LeakDC.ar(SinOsc.ar((ratio1*freq)+osc2,mul:0.5));

//osc block 2

	osc3=SinOsc.ar(freq*ratio3*env2,mul:freq*ratio3*env2*index3);
	osc4=SinOsc.ar(((freq*ratio4*env2)+osc3),mul:freq*ratio4*env2*index4);
	osc5=SinOsc.ar(((freq*ratio5*env2)+osc4),mul:freq*ratio5*env2*index5);
	osc6=LeakDC.ar(SinOsc.ar((freq*ratio6)+osc5,mul:0.5));


//envelopes
	env1=EnvGen.ar(Env.perc(env1att,env1rel),doneAction:2);
	env3=EnvGen.ar(Env.perc(env3att,env3rel),doneAction:2);

//free the synth
	FreeSelf.kr(Done.kr(env1) * Done.kr(env3));


	sound=Limiter.ar(((osc1*env1)+(osc6*env3))*amp);

	sound=Splay.ar(sound,splay,1,0.0);
	Out.ar(0, sound);
	}
).add;
)

////////////////////// \pattern installation
(
~pat = Pdef(\a,
    Pbind(
        \instrument, \fm,
        \dur, Pseq([10, 10, 15, 10, 20], inf),
        \freq, Pseq([
            [30, 34, 37, 42],
            [32, 35, 39, 44],
            [30, 34, 37, 41],
            [29, 33, 36, 41],
            [30, 34, 37, 42]
        ], inf).collect({ |chord| chord.collect(_ + Prand([0, 2, 5], 1)).midicps }),
        \amp, 0.3,
        \splay, Pwhite(0.4, 0.9, inf),
        \ratio1, Prand([1, 2, 3, 5], inf),
        \ratio2, Prand([1, 2, 3, 5], inf),
        \ratio3, Prand([1, 2, 3, 5], inf),
        \ratio4, Prand([1, 2, 3, 5], inf),
        \ratio5, Prand([1, 2, 3, 5], inf),
        \ratio6, Prand([1, 2, 3, 5], inf),
        \index2, Prand([1, 3, 5], inf),
        \index3, Prand([1, 3, 5], inf),
        \index4, Prand([1, 3, 5], inf),
        \index5, Prand([1, 3, 5], inf),
        \index6, Pwhite(2, 10, inf),
        \env1att, 5.004,
        \env1rel, 20,
        \env2att, 10.007,
        \env2rel, 10.007,
        \env3att, 8,
        \env3rel, 20
    )
).play;
)

~pat.stop;
