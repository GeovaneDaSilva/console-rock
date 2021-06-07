# TwoFactorBackupable allows a user to generate backup codes which
# provide one-time access to their account in the event that they have
# lost access to their two-factor device
#
# This code is taken from tinfoil's devise-two-factor gem with the following license
# The MIT License (MIT)
#
# Copyright (c) 2014 Tinfoil Security, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
module TwoFactorBackupable
  def self.required_fields(_klass)
    [:otp_backup_codes]
  end

  # 1) Invalidates all existing backup codes
  # 2) Generates <number_of_codes> backup codes
  # 3) Stores the hashed backup codes in the database
  # 4) Returns a plaintext array of the generated backup codes
  def generate_otp_backup_codes
    codes           = []
    hashed_codes    = []
    number_of_codes = 10
    code_length     = 32

    number_of_codes.times do
      code = SecureRandom.hex(code_length / 2)
      codes << code
      hashed_codes << Devise::Encryptor.digest(self.class, code)
    end

    self.otp_backup_codes = hashed_codes

    codes
  end

  # Returns true and invalidates the given code
  # iff that code is a valid backup code.
  def invalidate_otp_backup_code!(code)
    codes = otp_backup_codes || []

    found = codes.find { |backup_code| Devise::Encryptor.compare(self.class, backup_code, code) }

    if found
      codes.delete(found)
      update(otp_backup_codes: codes)
    else
      false
    end
  end

  # :nodoc
  module ClassMethods
    Devise::Models.config(self, :otp_backup_code_length,
                          :otp_number_of_backup_codes,
                          :pepper)
  end
end
