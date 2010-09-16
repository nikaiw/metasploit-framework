##
# $Id$
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


module Msf
module Sessions
module MeterpreterOptions

	def initialize(info = {})
		super(info)

		register_advanced_options(
			[
				OptBool.new('AutoLoadStdapi', [true, "Automatically load the Stdapi extension", true]),
				OptString.new('InitialAutoRunScript', [false, "An initial script to run on session creation (before AutoRunScript)", '']),
				OptString.new('AutoRunScript', [false, "A script to run automatically on session creation.", '']),
				OptBool.new('AutoSystemInfo', [true, "Automatically capture system information on initialization.", true]),
			], self.class)
	end

	#
	# Once a session is created, automatically load the stdapi extension if the
	# advanced option is set to true.
	#
	def on_session(session)
		super

		session.init_ui(self.user_input, self.user_output)

		if (datastore['AutoLoadStdapi'] == true)
			session.load_stdapi
			mod = framework.modules.create(session.via_exploit)
			
			if datastore['AutoSystemInfo']
				session.load_session_info
			end
			
			if session.railgun and session.railgun.shell32.IsUserAnAdmin()["return"] == true
				session.load_priv
				session.info += " (ADMIN)"
			end

		end

		if (datastore['InitialAutoRunScript'].empty? == false)
			args = datastore['InitialAutoRunScript'].split
			print_status("Session ID #{session.sid} (#{session.tunnel_to_s}) processing InitialAutoRunScript '#{datastore['InitialAutoRunScript']}'")
			session.execute_script(args.shift, args)
		end

		if (datastore['AutoRunScript'].empty? == false)
			args = datastore['AutoRunScript'].split
			print_status("Session ID #{session.sid} (#{session.tunnel_to_s}) processing AutoRunScript '#{datastore['AutoRunScript']}'")
			session.execute_script(args.shift, args)
		end
	end

end
end
end

