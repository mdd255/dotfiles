return {
	{
		'chrisgrieser/nvim-recorder',
		opts =
		{
			slots    = { 'a', 'b' },
			clear    = true,
			logLevel = vim.log.levels.INFO,
			mapping  = {
				startStopRecording = 'Q',
				playMacro          = 'q',
				editMacro          = '<Space>cq',
			}
		}
	},
}
