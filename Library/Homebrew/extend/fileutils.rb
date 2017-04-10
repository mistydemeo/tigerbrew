require "fileutils"
require "tmpdir"

# Homebrew extends Ruby's `FileUtils` to make our code more readable.
# @see http://ruby-doc.org/stdlib-1.8.7/libdoc/fileutils/rdoc/FileUtils.html Ruby's FileUtils API
module FileUtils
  # Create a temporary directory then yield. When the block returns,
  # recursively delete the temporary directory.
  def mktemp(prefix = name)
    prev = pwd
    tmp  = Dir.mktmpdir(prefix, HOMEBREW_TEMP)

    begin
      cd(tmp)

      begin
        yield
      ensure
        cd(prev)
      end
    ensure
      ignore_interrupts { rm_rf(tmp) }
    end
  end
  module_function :mktemp

  # @private
  alias_method :old_mkdir, :mkdir

  # A version of mkdir that also changes to that folder in a block.
  def mkdir(name, &_block)
    old_mkdir(name)
    if block_given?
      chdir name do
        yield
      end
    end
  end
  module_function :mkdir

  # The #copy_metadata method in all current versions of Ruby has a
  # bad bug which causes copying symlinks across filesystems to fail;
  # see #14710.
  # This was resolved in Ruby HEAD after the release of 1.9.3p194, but
  # never backported into the 1.9.3 branch. Fixed in 2.0.0.
  # The monkey-patched method here is copied directly from upstream fix.
  if RUBY_VERSION < "2.0.0"
    # @private
    class Entry_
      alias_method :old_copy_metadata, :copy_metadata if RUBY_VERSION > "1.8.2"
      def copy_metadata(path)
        st = lstat
        unless st.symlink?
          File.utime st.atime, st.mtime, path
        end
        begin
          if st.symlink?
            begin
              File.lchown st.uid, st.gid, path
            rescue NotImplementedError
            end
          else
            File.chown st.uid, st.gid, path
          end
        rescue Errno::EPERM
          # clear setuid/setgid
          if st.symlink?
            begin
              File.lchmod st.mode & 01777, path
            rescue NotImplementedError
            end
          else
            File.chmod st.mode & 01777, path
          end
        else
          if st.symlink?
            begin
              File.lchmod st.mode, path
            rescue NotImplementedError
            end
          else
            File.chmod st.mode, path
          end
        end
      end
    end
  end

  # Run `scons` using a Homebrew-installed version rather than whatever is in the `PATH`.
  def scons(*args)
    system Formulary.factory("scons").opt_bin/"scons", *args
  end

  # Run the `rake` from the `ruby` Homebrew is using rather than whatever is in the `PATH`.
  def rake(*args)
    system RUBY_BIN/"rake", *args
  end

  # Run `make` 3.81 or newer.
  # Uses the system make on Leopard and newer, and the
  # path to the actually-installed make on Tiger or older.
  def make(*args)
    if Utils.popen_read("/usr/bin/make", "--version").match(/Make (\d\.\d+)/)[1] > "3.80"
      system "/usr/bin/make", *args
    else
      make = Formula["make"].opt_bin/"make"
      make_path = make.exist? ? make.to_s : (Formula["make"].opt_bin/"gmake").to_s
      system make_path, *args
    end
  end

  if method_defined?(:ruby)
    # @private
    alias_method :old_ruby, :ruby
  end

  # Run the `ruby` Homebrew is using rather than whatever is in the `PATH`.
  def ruby(*args)
    system RUBY_PATH, *args
  end

  # Run `xcodebuild` without Homebrew's compiler environment variables set.
  def xcodebuild(*args)
    removed = ENV.remove_cc_etc
    system "xcodebuild", *args
  ensure
    ENV.update(removed)
  end
end
