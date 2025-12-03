# app/models/concerns/ean_normalizer.rb
module EanNormalizer
  extend ActiveSupport::Concern

  class_methods do
    # Normalise un EAN brut venant d'Excel / CSV / scannette
    # - force en string
    # - enlève tout sauf les chiffres
    # - corrige le bug "13 chiffres + 0 final"
    # - ne renvoie une valeur que si on a exactement 13 chiffres au final
    def normalize_ean(raw)
      return nil if raw.nil?

      str = raw.to_s.strip

      # Enlève tout sauf les chiffres (vire .0, espaces, etc.)
      digits = str.gsub(/\D/, "")

      # Cas typique : 14 chiffres qui finissent par 0 -> on coupe le 0 de trop
      if digits.length == 14 && digits.end_with?("0")
        digits = digits[0, 13]
      end

      # Ici tu peux décider de n'accepter QUE les EAN-13
      return digits if digits.length == 13

      # Sinon, on considère que c'est invalide
      nil
    end
  end
end
