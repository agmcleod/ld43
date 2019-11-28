mod spell;
pub use self::spell::*;

pub enum SPELL_STATUS_TYPE {
  ARCANE,
  FIRE,
  FROST,
}

impl SPELL_STATUS_TYPE {
  fn to_str(&self) -> &str {
    match self {
      SPELL_STATUS_TYPE::ARCANE => "arcane",
      SPELL_STATUS_TYPE::FIRE => "fire",
      SPELL_STATUS_TYPE::FROST => "frost",
    }
  }

  fn from_str(value: &str) {
    match value {
      "arcane" => SPELL_TYPE::ARCANE,
      "fire" => SPELL_TYPE::FIRE,
      "frost" => SPELL_TYPE::FROST,
      _ => panic!("Invalid type {:?}", value)
    }
  }
}


pub enum SPELL_TYPE {
  BALL,
  WAVE,
  SHEILD,
}

impl SPELL_TYPE {
  fn to_str(&self) -> &str {
    match self {
      SPELL_TYPE::BALL => "ball",
      SPELL_TYPE::WAVE => "wave",
      SPELL_TYPE::SHIELD => "shield",
    }
  }

  fn from_str(value: &str) {
    match value {
      "ball" => SPELL_TYPE::BALL,
      "wave" => SPELL_TYPE::WAVE,
      "shield" => SPELL_TYPE::SHEILD,
      _ => panic!("Invalid type {:?}", value),
    }
  }
}
