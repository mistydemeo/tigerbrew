module MacOSHardware
  # These methods use info spewed out by sysctl.
  # Look in <mach/machine.h> for decoding info.
  def cpu_type
    @@cpu_type ||= `/usr/sbin/sysctl -n hw.cputype`.to_i

    case @@cpu_type
    when 7
      :intel
    when 18
      :ppc
    else
      :dunno
    end
  end

  def ppc_model
    # Note: This list is defined in: /usr/include/mach/machine.h
    types = %w[POWERPC_ALL
      POWERPC_601
      POWERPC_602
      POWERPC_603
      POWERPC_603e
      POWERPC_603ev
      POWERPC_604
      POWERPC_604e
      POWERPC_620
      POWERPC_750
      POWERPC_7400
      POWERPC_7450]
    type100 = 'POWERPC_970'
    
    @@ppc_model ||= `/usr/sbin/sysctl -n hw.cpusubtype`.to_i
    if @@ppc_model == 100
      type100.downcase.to_sym
    elsif @@ppc_model <= 0 or @@ppc_model > types.length
      :dunno
    else
      types[@@ppc_model].downcase.to_sym
    end
  end

  def ppc_family
    # pre-750 hardware is unsupported by OS X
    case ppc_model
    when :powerpc_750 then :g3
    when :powerpc_7400 then :g4
    when :powerpc_7450 then :g4e
    when :powerpc_970 then :g5
    end
  end

  def intel_family
    @@intel_family ||= `/usr/sbin/sysctl -n hw.cpufamily`.to_i

    case @@intel_family
    when 0x73d67300 # Yonah: Core Solo/Duo
      :core
    when 0x426f69ef # Merom: Core 2 Duo
      :core2
    when 0x78ea4fbc # Penryn
      :penryn
    when 0x6b5a4cd2 # Nehalem
      :nehalem
    when 0x573B5EEC # Arrandale
      :arrandale
    when 0x5490B78C # Sandy Bridge
      :sandybridge
    when 0x1F65E835 # Ivy Bridge
      :ivybridge
    else
      :dunno
    end
  end

  def any_family
    case self.cpu_type
    when :intel
      Hardware.intel_family
    when :ppc
      Hardware.ppc_family
    else
      :dunno
    end
  end

  def processor_count
    @@processor_count ||= `/usr/sbin/sysctl -n hw.ncpu`.to_i
  end

  def is_64_bit?
    return @@is_64_bit if defined? @@is_64_bit
    @@is_64_bit = sysctl_bool("hw.cpu64bit_capable")
  end

protected
  def sysctl_bool(property)
    result = nil
    IO.popen("/usr/sbin/sysctl -n #{property} 2>/dev/null") do |f|
      result = f.gets.to_i # should be 0 or 1
    end
    $?.success? && result == 1 # sysctl call succeded and printed 1
  end
end
