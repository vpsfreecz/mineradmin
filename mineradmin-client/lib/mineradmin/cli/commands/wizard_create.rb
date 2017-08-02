require 'mrdialog'

module MinerAdmin::CLI::Commands
  class WizardCreate < HaveAPI::CLI::Command
    cmd :wizard, :create
    desc "Wizard for creating new user programs"

    def options(opts)
      @opts = {}

      opts.on('--log FILE', 'Log dialog commands into FILE') do |v|
        @opts[:logger] = Logger.new(v)
      end
    end

    # 1) Select miner type
    # 2) Configure label
    # 3) Select node
    # 4) Select GPUs
    # 5) Configure cmdline
    # 6) Start/attach
    def exec(args)
      @dialog = MRDialog.new

      unless @dialog.which("dialog")
        warn "dialog executable not found in $PATH"
        exit(false)
      end

      @dialog.logger = @opts[:logger]
      @dialog.clear = true

      @gpus = @api.gpu.index

      prog = miner_type || quit
      label = get_label || quit
      node = select_node || quit

      gpus = []
      until gpus.any?
        gpus = select_gpus(node) || quit
      end

      cmdline = get_cmdline || quit
      post = post_create || quit
      confirm(prog, label, node, gpus, cmdline, post) || quit
      create(prog, label, node, gpus, cmdline, post)
    end

    protected
    def quit
      clear
      puts "Cancelled"
      exit
    end

    def miner_type
      text = <<END
Select miner type:
END
      @dialog.title = 'Select miner type'

      programs = @api.program.index
      choices = programs.response.map do |p|
        [p[:label], p[:description] && p[:description].split("\n")[0]]
      end

      height = 0
      width = 0
      menu_height = 6

      ret = @dialog.menu(text, choices, height, width, menu_height)
      return false unless ret

      programs.response.detect { |p| p[:label] == ret }
    end

    def get_label
      @dialog.clear = true
      @dialog.title = 'Configure label'

      text = <<END
Please configure a label for your miner. It can be any string
using which you can organize your miners.
END

      height = 16
      width = 70
      init = ""
      @dialog.inputbox(text, height, width, init)
    end

    def select_node
      nodes = {}
      node_gpus = {}

      @gpus.response.each do |gpu|
        name = gpu[:node][:name] + '@' + gpu[:node][:domain]
        nodes[name] = gpu[:node]
        node_gpus[name] ||= 0
        node_gpus[name] += 1
      end

      choices = node_gpus.map { |k, v| [k, "#{v} GPUs available"] }

      text = <<END
Select on which node you want your miner to run.
END

      height = 0
      width = 0
      menu_height = 6

      @dialog.title = 'Select node'
      ret = @dialog.menu(text, choices, height, width, menu_height)
      return false unless ret

      nodes[ret]
    end

    def select_gpus(node)
      choices = @gpus.response.select { |g| g[:node][:id] == node[:id] }.map do |g|
        [g[:uuid], "#{g[:name]} (##{g[:id]})", false]
      end

      text = <<END
Select GPUS the miner should use.
END

      @dialog.title = 'Select GPUs'
      ret = @dialog.checklist(text, choices)
      return false unless ret

      @gpus.response.select { |g| ret.include?(g[:uuid]) }

    rescue EOFError
      []
    end

    def get_cmdline
      @dialog.clear = true
      @dialog.title = 'Configure command arguments'

      text = <<END
Here you can add custom command line options for your miner.
Most certainly, you will want to configure pool address
and your username. Consult your miner's manual to get a list
of possible options.
END

      height = 16
      width = 70
      init = ""
      @dialog.inputbox(text, height, width, init)
    end

    def post_create
      text = <<END
Select what should happen when this miner is created.
END

      choices = [
        ["Nothing", "Do not start the miner"],
        ["Start", "Start the miner after it is created"],
        ["Start & Attach", "Start the miner and attach to it"],
      ]

      height = 0
      width = 0
      menu_height = 6

      @dialog.title = 'Post create action'
      ret = @dialog.menu(text, choices, height, width, menu_height)
      return false unless ret

      case ret
      when "Nothing"
        :nothing
      when "Start"
        :start
      when "Start & Attach"
        :attach

      else
        return false
      end
    end

    def confirm(prog, label, node, gpus, cmdline, post)
      @dialog.title = "Confirmation"

      text = <<END
The following miner is going to be created:

  Program:
    #{prog[:label]}
  Label:
    #{label}
  Arguments:
    #{cmdline}
  Node:
    #{node[:name]}@#{node[:domain]}
  GPUs:
    #{confirm_gpus(gpus)}
  After:
    #{confirm_post(post)}

Do you wish to create the miner?
END

      @dialog.yesno(text, 0, 0)
    end

    def confirm_gpus(gpus)
      gpus.map do |gpu|
        "#{gpu[:name]} (UUID #{gpu[:uuid]}, ID ##{gpu[:id]})"
      end.join((' '*13) + "\n")
    end

    def confirm_post(post)
      case post
      when :nothing
        "Just create, do not start"

      when :start
        "Start the miner"

      when :attach
        "Start the miner and attach to it"
      end
    end

    def create(prog, label, node, gpus, cmdline, post)
      @dialog.title = 'Progress'

      height = 30
      width = 70
      percent = 0

      description = "Creating the miner"
      id = nil

      @dialog.programbox(description, height, width) do |f|
        f.puts "Creating the user program..."

        user_prog = @api.userprogram.create(
          program: prog[:id],
          node: node[:id],
          label: label,
          cmdline: cmdline,
        )
        id = user_prog.response[:id]

        f.puts "User program ID is ##{id}"
        f.puts "Adding GPUs..."

        gpus.each do |gpu|
          f.puts "  adding #{gpu[:name]} (UUID #{gpu[:uuid]}, ID ##{gpu[:id]})"

          @api.userprogram.gpu.create(id,
            gpu: gpu[:id]
          )
        end

        if post == :start
          f.puts "Starting the miner"
          @api.userprogram.start(id)

          f.puts "Done!"

        elsif post == :attach
          f.puts "Press enter to start and attach the miner"
        end
      end

      if post == :attach
        clear
        puts "Attaching to user program ##{id}"

        pid = Process.fork do
          c = UserProgramAttach.new(@global_opts, @api)
          c.exec([id.to_s])
        end

        sleep(1.5)
        @api.userprogram.start(id)
        Process.wait(pid)

      else
        puts "Created user program with ID ##{id}"
      end
    end

    def clear
      $stdout.write(`clear`)
    end
  end
end
