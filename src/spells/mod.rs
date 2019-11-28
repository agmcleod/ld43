mod spell;
pub use self::spell::*;

#[derive(PartialEq)]
pub enum SpellStatusType {
  ARCANE,
  FIRE,
  FROST,
}

impl SpellStatusType {
  fn to_str(&self) -> &str {
    match self {
      SpellStatusType::ARCANE => "arcane",
      SpellStatusType::FIRE => "fire",
      SpellStatusType::FROST => "frost",
    }
  }

  fn from_str(value: &str) -> SpellStatusType {
    match value {
      "arcane" => SpellStatusType::ARCANE,
      "fire" => SpellStatusType::FIRE,
      "frost" => SpellStatusType::FROST,
      _ => SpellStatusType::ARCANE,
    }
  }
}

#[derive(PartialEq)]
pub enum SpellType {
  BALL,
  WAVE,
  SHIELD,
}

impl SpellType {
  fn to_str(&self) -> &str {
    match self {
      SpellType::BALL => "ball",
      SpellType::WAVE => "wave",
      SpellType::SHIELD => "shield",
    }
  }

  fn from_str(value: &str) -> SpellType {
    match value {
      "ball" => SpellType::BALL,
      "wave" => SpellType::WAVE,
      "shield" => SpellType::SHIELD,
      _ => SpellType::BALL,
    }
  }
}
