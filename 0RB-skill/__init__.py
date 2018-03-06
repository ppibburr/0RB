# Copyright 2016 Mycroft AI, Inc.
#
# This file is part of Mycroft Core.
#
# Mycroft Core is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Mycroft Core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mycroft Core.  If not, see <http://www.gnu.org/licenses/>.

import re
from os.path import dirname, join

from adapt.intent import IntentBuilder
from mycroft import MycroftSkill, intent_handler
from subprocess import call

# TODO - Localization

class SpeakSkill(MycroftSkill):
    def initialize(self):
		self.add_event('mycroft.audio.service.next', self.next)
		self.add_event('mycroft.audio.service.prev', self.prev)
		self.add_event('mycroft.audio.service.pause', self.pause)
		self.add_event('mycroft.audio.service.resume', self.resume)
		self.add_event('mycroft.audio.service.stop', self.stop)
    
    @intent_handler(IntentBuilder("").require("Speak").require("Words"))
    def speak_back(self, message):
        """
            Repeat the utterance back to the user.

            TODO: The method is very english centric and will need
                  localization.
        """
        # Remove everything up to the speak keyword and repeat that
        utterance = message.data.get('utterance')
        repeat = re.sub('^.*?' + message.data['Speak'], '', utterance)
        
        call(["curl", "-d", "{\"text\": \""+repeat+"\"}", "localhost:4567/command"])

    def stop(self):
        #
        call(["curl", "-d", "{\"text\": \"stop\"}", "localhost:4567/command"])
        pass

    def prev(self):
        #
        call(["curl", "-d", "{\"text\": \"prev\"}", "localhost:4567/command"])
        pass

    def next(self):
        #
        call(["curl", "-d", "{\"text\": \"next\"}", "localhost:4567/command"])
        pass
        
    def pause(self):
        #
        call(["curl", "-d", "{\"text\": \"pause\"}", "localhost:4567/command"])
        pass
        
    def resume(self):
        #
        call(["curl", "-d", "{\"text\": \"resume\"}", "localhost:4567/command"])
        pass

def create_skill():
    return SpeakSkill()
