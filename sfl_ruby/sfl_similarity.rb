
def binary_compare(array1, array2)
  # array1 => activation_vector
  # array2 => error_vector
  if array1.length != array2.length then
    raise ArgumentError, "Arrays of different length."
  end
  m11 = m10 = m01 = m00 = 0
  array1.each_index do |i|
    if array1[i] == 1 and array2[i] == 1 then
      # activated and error
      m11 += 1
    elsif array1[i] == 1 and array2[i] == 0 then
      # activated and NO error
      m10 += 1
    elsif array1[i] == 0 and array2[i] == 1 then
      # NOT activated and error
      m01 += 1
    elsif array1[i] == 0 and array2[i] == 0 then
      # NOT activated and NO error
      m00 += 1
    end
  end # array1.each
  # m11 => activated with error
  # m10 => activated without error
  # m01 => not activated with error
  # m00 => not activated without error -> no useful information?
  return m11, m10, m01, m00
end

def usage(array1, array2)
  # count the absolute number of times that a component was covered (used)
  used = 0
  array1.each do |v|
    if v == 1 then
      used += 1
    end
  end
  return :usage, (used / array1.length.to_f).round(3)
end

def fail(array1, array2)
  # how many times was a component active in a failed run?
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  return :fail, act_err
end

def pass(array1, array2)
  # how many times was a component active in a passed run?
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  return :pass, act_noerr
end

def nofail(array1, array2)
  # how many times was a component inactive in a failed run
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  return :nofail, noact_err
end

def nopass(array1, array2)
  # how many times was a component inactive in a passed run 
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  return :nopass, noact_noerr
end

def exoner_passed(array1, array2)
  # counts how many times a component was activated when NO error was observed
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  # here, we are interested in activated AND NO error
  return :exoner_passed, act_noerr+1
end

def exoner_failed(array1, array2)
  # counts how many times a component was not activated WHEN an error was observed
  act_err, act_noerr, noact_err, noact_noerr = binary_compare(array1, array2)
  # here we are interested in NOT activated AND error
  return :exoner_failed, noact_err+1
end

# ===== DISTANCE MEASURES =====

def hamming(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  d = m10 + m01
  return :hamming, d 
end

def meanham(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = (m10 + m01) / (m11 + m10 + m01 + m00).to_f
  rescue ZeroDivisionError
    return :meanham, 0.000
  end
  return :meanham, d.round(3)
end

def euclid(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  d = Math.sqrt(m10 + m01).to_f
  return :euclid, d.round(3)
end

def euclid2(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  d = Math.sqrt((m10 + m01)**2).to_f
  return :euclid2, d.round(3)
end

def vari(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = (m10 + m01) / 4*(m11 + m10 + m01 + m00).to_f
  rescue ZeroDivisionError
    return :vari, 0.000
  end
  return :vari, d.round(3)
end

def sizdif(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = ((m10 + m01)**2) / ((m11 + m10 + m01 + m00)**2).to_f
  rescue ZeroDivisionError
    return :sizdif, 0.000
  end
  return :sizdif, d.round(3)
end

def shpdif(array1, array2) # not useful
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  begin
    d = (n*(m10 + m01) - (m10-m01)**2) / ((m11 + m10 + m01 + m00)**2).to_f
  rescue ZeroDivisionError
    return :shpdif, 0.000
  end
  return :shpdif, d.round(3)
end

def patdif(array1, array2) # not useful
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = 4*m10*m01 / ((m11 + m10 + m01 + m00)**2).to_f
  rescue ZeroDivisionError
    return :patdif, 0.000
  end
  return :patdif, d.round(3)
end

def lance(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = (m10 + m01) / (2*m11 + m10 + m01).to_f
  rescue ZeroDivisionError
    return :lance, 0.000
  end
  return :lance, d.round(3)
end

def chord(array1, array2) # not useful
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    d = Math.sqrt(2* (1 - (m11 / Math.sqrt((m11+m10)*(m11+m01)))).to_f)
  rescue ZeroDivisionError
    return :chord, 0.000
  end
  return :chord, 0.000 if d.nan?
  return :chord, d.round(3)
end

# SIMILARITY COEFFICIENTS
# taken from the paper: A Survey of Binary Similarity and Distance Measures by S.-S. Choi, et. al.

# ===== MEASURES without m00 (negative match exclusive) =====

def ochiai(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  begin
    s = m11 / Math.sqrt( (m11 + m10) * (m11 + m01) ).to_f 
  rescue ZeroDivisionError
    return :ochiai, 0.000
  end
  return :ochiai, 0.000 if s.nan?
  return :ochiai, s.round(3)
end

def cos(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11 / Math.sqrt( (m11 + m10) * ((m11 + m01)**2) ).to_f 
  rescue ZeroDivisionError
    return :cos, 0.000
  end
  return :cos, 0.000 if s.nan?
  return :cos, s.round(3)
end

def jaccard(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11 / (m01 + m10 + m11).to_f
  rescue ZeroDivisionError
    return :jaccard, 0.000
  end
  return :jaccard, 0.000 if s.nan?
  return :jaccard, s.round(3)
end

def w3jaccard(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  begin
    s = 3*m11 / (3*m11 + m10 + m01).to_f
  rescue ZeroDivisionError
    return :w3jaccard, 0.000
  end
  return :w3jaccard, 0.000 if s.nan?
  return :w3jaccard, s.to_f.round(3) 
end

def forbesi(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  n = array1.size
  begin
    s = n*m11 / ((m11+m10)*(m11+m01)).to_f
  rescue ZeroDivisionError
    return :forbesi, 0.000
  end
  return :forbesi, 0.000 if s.nan?
  return :forbesi, s.round(3) 
end

def fossum(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  n = array1.size
  begin
    s = n*(m11-0.5)**2 / ((m11+m10)*(m11+m01)).to_f
  rescue ZeroDivisionError
    return :fossum, 0.000
  end
  return :fossum, 0.000 if s.nan?
  return :fossum, s.round(3) 
end

def sorgfrei(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  begin
    s = m11**2 / ((m11+m10)*(m11+m01)).to_f
  rescue ZeroDivisionError
    return :sorgfrei, 0.000
  end
  return :sorgfrei, 0.000 if s.nan?
  return :sorgfrei, s.round(3) 
end

def tarwid(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  n = array1.size
  begin
    s = n*m11 - (m11+m10)*(m11+m01) / (n*m11 + ((m11+m10)*(m11+m01))).to_f
  rescue ZeroDivisionError
    return :tarwid, 0.000
  end
  return :tarwid, 0.000 if s.nan?
  return :tarwid, s.round(3)
end

def dice(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  begin
    s = 2*m11 / (2*m11 + m10 + m01).to_f
  rescue ZeroDivisionError
    return :dice, 0.000
  end
  return :dice, 0.000 if s.nan?
  return :dice, s.round(3) 
end

def neili(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2) 
  begin
    s = 2*m11 / (m11+m10+m11+m01).to_f
  rescue ZeroDivisionError
    return :neili, 0.000
  end
  return :neili, 0.000 if s.nan?
  return :neili, s.round(3) 
end

def sokal1(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11 / (m11 + 2*m10 + m01).to_f
  rescue ZeroDivisionError
    return :sokal1, 0.000
  end
  return :socal1, 0.000 if s.nan?
  return :sokal1, s.round(3)
end




# ===== MEASURES with m00 (negative match inclusive) =====

def ochiai2(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11*m00 / Math.sqrt((m11+m10)*(m11+m01)*(m10+m00)*(m01+m00)).to_f
  rescue ZeroDivisionError
    return :ochiai2, 0.000
  end
  return :ochiai2, 0.000 if s.nan?
  return :ochiai2, s.round(3)
end

def ample(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = (m11/(m01+m11).to_f - m10/(m00+m10).to_f).abs
  rescue ZeroDivisionError
    return :ample, 0.000
  end
  return :ample, s.round(3)
end

def tarantula(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11/(m11+m01).to_f / (m11/(m11+m01).to_f + m10/(m10+m00).to_f)
  rescue ZeroDivisionError
    return :tarantula, 0.000
  end
  return :tarantula, 0.000 if s.nan?
  return :tarantula, s.round(3)
end

def sokalm(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = (m11+m00) / (m11 + m10 + m01 + m00).to_f
  rescue ZeroDivisionError
    return :sokalm, 0.000
  end
  return :socalm, 0.000 if s.nan?
  return :sokalm, s.round(3)
end

def sokal2(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = 2* (m11+m00) / (2*m11 + m10 + m01 + 2*m00).to_f
  rescue ZeroDivisionError
    return :sokal2, 0.000
  end
  return :socal2, 0.000 if s.nan?
  return :sokal2, s.round(3)
end

def tanimoto(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = (m11+m00) / (m11 + 2*(m10+m01) + m00).to_f
  rescue ZeroDivisionError
    return :tanimoto, 0.000
  end
  return :tanimoto, 0.000 if s.nan?
  return :tanimoto, s.round(3)
end

def faith(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = (m11 + 0.5*m00) / (m11 + m10 + m01 +m00).to_f
  rescue ZeroDivisionError
    return :sokal1, 0.000
  end
  return :faith, 0.000 if s.nan?
  return :faith, s.round(3)
end

def gower(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = (m11 + 0.5*m00) / (m11 + 0.5*(m10 + m01) + m00).to_f
  rescue ZeroDivisionError
    return :gower, 0.000
  end
  return :gower, 0.000 if s.nan?
  return :gower, s.round(3)
end

def innerprod(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  s = 1 / (m11 + m00).to_f
  return :innerprod, s.round(3)
end

def russell(array1, array2) # much worse than ochiai, NOT suitable
  m11, m10, m01, m00 = binary_compare(array1, array2)
  begin
    s = m11 / (m11 + m10 + m01 + m00).to_f
  rescue ZeroDivisionError
    return :russell, 0.000
  end
  return :russell, 0.000 if s.nan?
  return :russell, s.round(3)
end

def stiles(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  d1 = n * (((m11*m00 - m10*m01).abs - n/2)**2).to_f
  d2 = (m11+m10)*(m11+m01)*(m10+m00)*(m01+m00).to_f
  begin
    s = Math.log10( d1 / d2 ).to_f 
  rescue ZeroDivisionError
    return :stiles, 0.000
  end
  return :stiles, 0.000 if s.nan?
  return :stiles, s.round(3)
end

def goodman(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  sig1 = [m11,m10].max + [m01,m00].max + [m10,m00].max
  sig0 = [m11+m01, m10+m00].max + [m11+m10, m01+m00].max
  begin
    s = (sig1 - sig0) / ( 2*n - sig0 ).to_f
  rescue ZeroDivisionError
    return :goodman, 0.000
  end
  return :goodman, 0.000 if s.nan?
  return :goodman, s.round(3)
end

def anderbg(array1, array2)
  m11, m10, m01, m00 = binary_compare(array1, array2)
  n = array1.size
  sig1 = [m11,m10].max + [m01,m00].max + [m10,m00].max
  sig0 = [m11+m01, m10+m00].max + [m11+m10, m01+m00].max
  begin
    s = (sig1 - sig0) / (2*n).to_f
  rescue ZeroDivisionError
    return :anderbg, 0.000
  end
  return :anderbg, 0.000 if s.nan?
  return :anderbg, s.round(3)
end


# ===== OWN EXPERIMENTAL MEASURES =====

def a(array1, array2)
  n = array1.size
  m11, m10, m01, m00 = binary_compare(array1, array2)
  return :a, (m11/n.to_f).round(3)
end

def b(array1, array2)
  n = array1.size
  m11, m10, m01, m00 = binary_compare(array1, array2)
  return :b, (m10/n.to_f).round(3)
end

def c(array1, array2)
  n = array1.size
  m11, m10, m01, m00 = binary_compare(array1, array2)
  return :c, (m01/n.to_f).round(3)
end

def d(array1, array2)
  n = array1.size
  m11, m10, m01, m00 = binary_compare(array1, array2)
  return :d, (m00/n.to_f).round(3)
end



















