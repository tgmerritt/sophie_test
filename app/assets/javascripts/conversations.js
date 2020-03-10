window.onload = function () {
    let fmReady = false;
    let devices = null;
    let selectedMic = null;
    let selectedCam = null;
    let selectedSpeaker = null;
    let speechEvents = null;
    var token = document.getElementById('msg').dataset.userToken;

    const uneeq = new Uneeq({
        url: 'https://api.us.uneeq.io',
        // conversationId: '1507ece5-dafd-49fd-8b8b-699f40836f43', // dialog-flow
        // conversationId: '9c7dafd7-2d90-49aa-b66a-2dfc394865e1', // sophie-digital-human-test
        // conversationId: '618ac47d-7e60-413e-9381-0e4671e6f572', // This conversation ID is for local debugging only
        conversationId: '3c4a18bf-251d-4c81-a302-edd63d12cc24', // pandorabots
        avatarVideoContainerElement: document.getElementById('avatar-container'),
        // localVideoContainerElement: document.getElementById('local-container'), // sendLocalVideo: false makes this irrelevant
        customData: {},
        logging: true,
        sendLocalVideo: false
    });

    uneeq.initWithToken(token);

    window.uneeq = uneeq;

    function switchText() {
        if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
            document.getElementById('prompt').innerHTML = "Press and hold screen to speak";
        } else {
            document.getElementById('prompt').innerHTML = "Hold <b>space</b> to speak.";
        }
    }

    switchText();

    function fmReadyHandler() {
        addKeyListeners();
        fmReady = true;
    }

    function addListeningText() {
        document.getElementById('prompt').innerHTML = "Listening...";
    }

    function addActivePrompt() {
        document.getElementById('prompt').removeAttribute('class', 'prompt');
        addListeningText();
        document.getElementById('prompt').setAttribute('class', 'prompt-active');
    }

    function addNonActivePrompt() {
        document.getElementById('prompt').removeAttribute('class', 'prompt-active');
        switchText();
        document.getElementById('prompt').setAttribute('class', 'prompt');
    }

    function pressingDown() {
        addActivePrompt();
        uneeq.startRecording();
    }

    function notPressingDown() {
        addNonActivePrompt();
        uneeq.stopRecording();
    }

    function addAvatarTranscript(msg) {
        let newElement = document.createElement('div');
        newElement.classList.add('transcript-msg');
        newElement.innerHTML = msg;
        const transcript = document.getElementById('transcript');
        // Clear any previously added transcript
        transcript.innerText = '';
        // Add the new transcript
        transcript.appendChild(newElement);
        transcript.scrollTop = transcript.scrollHeight;
    }

    function updateDeviceList() {
        const addOptionToSelect = (device, selectElem) => {
            const option = document.createElement('option');
            option.innerHTML = device.label;
            option.value = device.deviceId;
            selectElem.appendChild(option);
        };
        // No longer necessary if we aren't using video
        // if (devices && devices.videoInput) {
        //     // Set a default camera if there isn't one
        //     if (selectedCam === null && devices.videoInput.length > 0) {
        //         selectedCam = devices.videoInput[0].deviceId;
        //     }
        //     const selectElem = document.getElementById('cameraSelect');
        //     selectElem.innerHTML = '';
        //     devices.videoInput.forEach((cam) => addOptionToSelect(cam, selectElem));
        //     selectElem.value = selectedCam;
        // }
        if (devices && devices.audioInput) {
            // Set a default microphone if there isn't one
            if (selectedMic === null && devices.audioInput.length > 0) {
                selectedMic = devices.audioInput[0].deviceId;
            }
            const selectElem = document.getElementById('micSelect');
            selectElem.innerHTML = '';
            devices.audioInput.forEach((mic) => addOptionToSelect(mic, selectElem));
            selectElem.value = selectedMic;
        }
        if (devices && devices.audioOutput) {
            // Set a default speaker if there isn't one
            if (selectedSpeaker === null && devices.audioOutput.length > 0) {
                selectedSpeaker = devices.audioOutput[0].deviceId;
            }
            const selectElem = document.getElementById('speakerSelect');
            selectElem.innerHTML = '';
            devices.audioOutput.forEach((speaker) => addOptionToSelect(speaker, selectElem));
            selectElem.value = selectedSpeaker;
        }
    }

    function addKeyListeners() {
        // When the spacebar is pressed and held, UneeQ will begin to listen to the microphone
        document.addEventListener('keydown', (e) => {
            if (e.code === 'Space' && !e.repeat && e.target.type !== 'text') {
                addActivePrompt()
                uneeq.startRecording();
            }
        });

        // When the held spacebar is released, the recording is finalized and sent to UneeQ for speech-to-text translation
        document.addEventListener('keyup', (e) => {
            if (e.code === 'Space' && !e.repeat && e.target.type !== 'text') {
                addNonActivePrompt();
                uneeq.stopRecording();
            }
        });

        // Touch screen support - allows the user to press on the glass of their phone or tablet to start "listening"
        // Releasing this press will end the recording and send the spoken input to UneeQ for processing
        let touchScreen = document.getElementById('avatar-container');
        touchScreen.addEventListener('touchstart', pressingDown, false);
        touchScreen.addEventListener('touchend', notPressingDown, false);
    }

    // Subscribe to UneeQ messages from the API, various response types, and trigger on certain actions
    uneeq.messages.subscribe((msg) => {
        switch (msg.uneeqMessageType) {
            case 'Ready':
                fmReadyHandler();
                break;
            case 'AvatarQuestionText':
                document.getElementById('local-transcript').innerHTML = msg.question;
                break;
            case 'AvatarAnswerText':
                addAvatarTranscript(msg.answer);
                break;
            case 'AvatarAnswerContent':
                this.console.log("Got AvatarAnswerContent msg");
                if (this.uneeq.options.conversationId === '1507ece5-dafd-49fd-8b8b-699f40836f43') {
                    if (msg.content !== '') {
                        addAvatarTranscript(msg.content);
                    }
                }
                break;
            case 'AvatarTextInputFinished':
                break;
            case 'AvatarUnavailable':
                document.getElementById('msg').innerHTML = 'Digital Human Unavailable. Session will begin when a digital human becomes available.';
                break;
            case 'AvatarAvailable':
                document.body.classList.add('live');
                document.getElementById('msg').innerHTML = 'Loading...';
                break;
            case 'DevicePermissionAllowed':
                break;
            case 'DeviceListUpdated':
                devices = msg.devices;
                updateDeviceList();
                break;
            case 'SetMicSuccess':
                selectedMic = msg.deviceId;
                break;
            case 'SetCamSuccess':
                selectedCam = msg.deviceId;
                break;
            case 'SetSpeakerSuccess':
                selectedSpeaker = msg.deviceId;
                break;
            case 'SessionEnded':
                document.getElementById('msg').innerHTML = 'Session Ended.';
                break;
            case 'SessionError':
                console.log("SessionError: " + msg.error);
                break;
            case 'SessionLive':
                this.console.log("Session Live - sending initial transcript to trigger demo");
                // For JP Dialogflow conversation, send start intent
                if (this.uneeq.options.conversationId === '1507ece5-dafd-49fd-8b8b-699f40836f43') {
                    uneeq.sendTranscript("jp train reservation demo start");
                }
                break;
            case 'ErrorEndingSession':
                console.error(msg.error);
                break;
            case 'SessionPaused':
                console.log("SessionPaused");
                break;
            case 'SessionResumed':
                console.log("SessionResumed");
                break;
            case 'ServiceUnavailable':
                console.log('ServiceUnavailable');
                break;
            case 'RecordingStarted':
                console.log('RecordingStarted');
                break;
            case 'RecordingStopped':
                console.log('RecordingStopped');
                break;
            case 'AvatarAnswer':
                var html = JSON.parse(msg.answerAvatar)
                if (html && html.instructions && html.instructions.displayHtml) {
                    addAvatarTranscript(html.instructions.displayHtml.html)
                }
                console.log('AvatarAnswer');
                break;
            case 'ClientMediaStreamUpdate':
                this.console.log(msg);
                break;
            case 'Warning':
                console.log(msg.msg);
                break;
            default:
                console.log('UneeQ: Unhandled message \'' + msg.faceMeMessageType + '\'');
                break;
        }
    });
}

function setHarkerState(enabled) {
    // I really hate that hoisting is a thing - and I'm not going to bother figuring out all the hoisting and non-hoisting going on with this function below
    // The code is not DRY at all because the pressingDown and notPressingDown functions defined inside window.load do what the below does, but because of hoisting and scope I can't access them
    // And I just can't be bothered to put time into figuring out why right now...

    if (enabled) {
        var stream = uneeq.deviceManager.mediaHandler.localStream$._value
        var options = {
            "threshold": "-35",
            "play": false
        };
        window.speechEvents = hark(stream, options);
        console.log("Enabling Harker");
        window.speechEvents.on('speaking', function () {
            console.log("Registering Harker Speech Event: speaking");
            document.getElementById('prompt').removeAttribute('class', 'prompt');
            document.getElementById('prompt').innerHTML = "Listening...";
            document.getElementById('prompt').setAttribute('class', 'prompt-active');
            uneeq.startRecording();
        });
        window.speechEvents.on('stopped_speaking', function () {
            console.log("Registering Harker Speech Event: stopped speaking");
            document.getElementById('prompt').removeAttribute('class', 'prompt-active');
            document.getElementById('prompt').innerHTML = "Hold <b>space</b> to speak.";
            document.getElementById('prompt').setAttribute('class', 'prompt');
            uneeq.stopRecording();
        });
        document.getElementById('harker-btn').style.display = 'none';
        document.getElementById('disable-harker-btn').style.display = 'block';
    } else {
        console.log("Disabling Harker");
        window.speechEvents.stop();
        document.getElementById('harker-btn').style.display = 'block';
        document.getElementById('disable-harker-btn').style.display = 'none';
    }
}

function askKeyPress(e) {
    if (e.key === 'Enter' && uneeq.ready.value === true) {
        console.log("Sending transcript to UneeQ: " + document.getElementById('askInput').value);
        uneeq.sendTranscript(document.getElementById('askInput').value);
        document.getElementById('askInput').value = '';
    }
}

function showSettings() {
    document.getElementById('settings').classList.add('show');
    updateDeviceList();
}

function hideSettings() {
    document.getElementById('settings').classList.remove('show');
}

function setPauseState(paused) {
    if (paused) {
        uneeq.pauseSession();
        document.getElementById('pause-btn').style.display = 'none';
        document.getElementById('resume-btn').style.display = 'block';
    } else {
        uneeq.resumeSession();
        document.getElementById('pause-btn').style.display = 'block';
        document.getElementById('resume-btn').style.display = 'none';
    }
}