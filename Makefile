CODELAB_ID := github-copilot-workshop
OUT_DIR := $(CODELAB_ID)
TEMP_DIR := temp-export

LATEST_VERSION := $(shell jq -r .defaultVersion $(OUT_DIR)/versions.json)

# localize-images: Markdown内のリモート画像URLをローカルに変換した一時ファイルを作成
#   claat はローカルMarkdownソース内のリモート画像URLを処理できないため (authHelper nil panic)、
#   事前にダウンロードしてパスを書き換えた一時コピーを使う
#   $(1) = 元のMarkdownファイル
#   $(2) = 一時Markdownファイル (加工用コピー)
define localize-images
	@cp $(1) $(2)
	@grep -oE '!\[[^]]*\]\(https?://[^)]+\.(png|jpg|jpeg|gif|svg|webp)\)' $(2) 2>/dev/null | \
	sed -E 's/.*\((https?:\/\/[^)]+)\)/\1/' | sort -u | while read -r url; do \
		fname=$$(basename "$$url"); \
		dest="$(OUT_DIR)/img/$$fname"; \
		if [ ! -f "$$dest" ]; then \
			echo "⬇️  $$url → $$dest"; \
			curl -sL -o "$$dest" "$$url"; \
		fi; \
		sed -i.bak "s|$${url}|$(OUT_DIR)/img/$${fname}|g" $(2); \
		rm -f $(2).bak; \
	done
endef

# export-codelab: claat export → コピー → 画像パス修正 → 後片付け
#   $(1) = ソースMarkdown
#   $(2) = 出力先ディレクトリ
define export-codelab
	$(call localize-images,$(1),.$(notdir $(1)))
	go tool claat export -o ./$(TEMP_DIR) .$(notdir $(1))
	$(RM) .$(notdir $(1))
	mkdir -p $(2)
	cp $(TEMP_DIR)/$(CODELAB_ID)/index.html $(2)/index.html
	# -i.bak は macOS (BSD sed) と Linux (GNU sed) の両方で動作するポータブルな書き方
	sed -i.bak 's|src="img/|src="../../img/|g' $(2)/index.html
	$(RM) $(2)/index.html.bak
	cp -r $(TEMP_DIR)/$(CODELAB_ID)/img/* $(OUT_DIR)/img/ 2>/dev/null || true
	$(RM) -r $(TEMP_DIR)
endef

.PHONY: export export-custom

# 最新バージョンのエクスポート: make export
# 別バージョンを指定: make export VERSION=v1.0.4
export: VERSION ?= $(LATEST_VERSION)
export:
	$(call export-codelab,workshop.md,$(OUT_DIR)/versions/$(VERSION))
	@echo "✅ $(VERSION) のエクスポートが完了しました"

# カスタムバージョンのエクスポート: make export-custom NAME=nri
export-custom:
	@test -n "$(NAME)" || (echo "❌ NAME を指定してください (例: make export-custom NAME=nri)" && exit 1)
	$(call export-codelab,workshop-$(NAME).md,$(OUT_DIR)/custom/$(NAME))
	@echo "✅ $(NAME) カスタムバージョンのエクスポートが完了しました"
