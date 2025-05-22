class Ffe < Formula
  desc "Parse flat file structures and print them in different formats"
  homepage "http://ff-extractor.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/ff-extractor/ff-extractor/0.3.5/ffe-0.3.5.tar.gz"
  sha256 "5ed5b4bf04bd8e2e438d8c37d3cec8ec681844b5318da8ac14565838c19c41da"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"source").write "EArthur Guinness   25"
    (testpath/"test.rc").write <<-EOS.undent
      structure personel_fix {
        type fixed
        record employee {
          id 1 E
          field EmpType 1
          field FirstName 7
          field LastName  11
          field Age 2
        }
      }
      output default {
        record_header "<tr>"
        data "<td>%t</td>"
        record_trailer "</tr>"
        no-data-print no
      }
    EOS

    system "#{bin}/ffe", "-c", "test.rc", "source"
  end
end
