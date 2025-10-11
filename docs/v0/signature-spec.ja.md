# rk v0 署名仕様（最小実装）

## 目的

- 誰でもブラウザだけで署名・検証できる、軽量・自己完結の署名仕様。
- 署名は「オリジナル（作者）」と「複製（再利用者）」の連結を表現できる。
- 透明性ログは任意（将来拡張）。v0 は完全オフライン検証を最優先。

## 用語

- AID: Author Identity Document（作者アイデンティティ文書）
- Signature Object: 署名コンテナ（JSON/CBOR）
- Manifest: 署名対象の正規化メタ（テキスト/添付/親参照等）
- rkfp: 公開鍵フィンガープリント（短い表示用）

## 暗号プリミティブ

- 署名: Ed25519（必須）
- ハッシュ: SHA-256（必須）、BLAKE3（任意併記）
- ドメイン分離: "rk/v0/signature"

## AID（作者アイデンティティ）

- 目的: ルート鍵・メンバー鍵・失効/ローテーション履歴の宣言。
- 表現: JSON（将来 CBOR 併用可）、did:key 相当の公開鍵表現を許容。

### 例

```json
{
  "type": "rk/aid-v0",
  "author": {
    "name": "Alice",
    "handles": ["@alice@example", "https://example.com/alice"]
  },
  "root": {
    "kid": "rk:key:z6Mkh...root",
    "pubkey": "base58btc",
    "alg": "ed25519"
  },
  "members": [
    {"kid": "rk:key:z6Mk...m1", "alg": "ed25519", "usage": ["sign"], "notBefore": 1735689600, "notAfter": 1798752000}
  ],
  "recovery": [{"kid": "rk:key:z6Mk...rec1", "usage": ["revoke","rotate"]}],
  "revocations": [],
  "rotations": [],
  "createdAt": 1735689600,
  "signature": "..."  // root が AID 全体（signature フィールド除外）へ署名
}
```

## Manifest（投稿・ファイル集合）

- 正規化: UTF-8、NFC、LF 改行。トリミングなし。URL は投稿画面の表示文字列をそのまま保持。
- 大きな添付は content-addressable（sha256）で参照、実体は別配布可。

### 例（tsuredure post）

```json
{
  "type": "rk/manifest-v0",
  "platform": "tsuredure-sns",
  "text": "こんにちは、rk 署名のテストです。",
  "lang": "ja",
  "attachments": [
    {"name":"photo.jpg","sha256":"...","size":123456,"mime":"image/jpeg","url":"https://.../photo.jpg"}
  ],
  "parents": [
    // 複製/リミックス元の署名ID（または署名オブジェクトのハッシュ）
  ],
  "tags": ["rk","p2p","webrtc"],
  "createdAt": 1735689600
}
```

### Signature Object（署名コンテナ）

```json
{
  "type": "rk/signature-v0",
  "alg": "ed25519",
  "kid": "rk:key:z6Mk...m1",         // 署名者の公開鍵識別子
  "rkfp": "rkfp:abcd-1234",         // 短縮表示用（検証UI用、検証には不要）
  "hash": { "algo": "sha256", "digest": "..." }, // Manifest のハッシュ
  "size": 512,                       // Manifest サイズ（任意）
  "parentSigs": [],                  // 連結署名（0=オリジナル）
  "time": 1735689600,
  "log": null,                       // v0 は null（将来: 透明性ログ証跡）
  "policy": {                        // 任意：機械可読ポリシ
    "license": "CC-BY-4.0",
    "ai": "disallow"
  },
  "signature": "..."                 // sign("rk/v0/signature" || canonicalize(body-without-signature))
}
```

## 検証手順（ブラウザ/CLI 共通）

1) Manifest の正規化→ハッシュ（SHA-256）
2) Signature Object の署名検証（kid の公開鍵で ed25519 verify）
3) AID 検証（kid が AID のアクティブメンバー鍵であること、失効/有効期間）
4) 連結署名の整合性（parentSigs が存在する場合、それぞれの署名検証）
5) すべて成功で「rk verified」

## UX ポイント

- オフライン完結（AID/Manifest/Signature があれば検証可）
- 検証リンク（URL フラグメントに圧縮ペイロード）や QR を生成し、他SNSへ貼れる
- 失効時は AID に失効宣言を追加し、検証UIで「失効済み」表示

## 将来拡張

- 透明性ログ（追記専用、監査証跡）
- Witness cosign（第三者共署名）
- DSSE/COSE 対応
