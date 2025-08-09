.PHONY: all check_tex check_file collect ncollect rcollect tur clean help
#xelatex 的执行路径
#如果你设置了环境变量，则不需要更改
TEXP=xelatex
TEX=$(TEXP) -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape

#当你修改 template.tex 时，请也更改这里的名字
#tex文件名，项目默认为 template.tex
FNAME=template
TEXFILE = $(FNAME).tex

CNAME=附件页
CFILE=$(CNAME).tex
COUT=附件索引页
COUTF=$(COUT).tex

TURFILE= 说明书.tex

all: pdf

# 自定义处理
# 检查文件是否存在
check_collectout:
	@if [ ! -f $(COUTF) ];then \
	    echo "错误: 文件$(COUTF)不存在！"; \
	    echo "请确保该文件在当前目录中。"; \
	    echo "或者Makefile中COUT 存在值错误，请予以修正。";\
	    exit 1; \
	else \
	    echo "文件$(COUTF) 存在，继续执行..."; \
	fi


check_collect:
	@if [ ! -f $(CFILE) ];then \
	    echo "错误: 文件$(CFILE)不存在！"; \
	    echo "请确保该文件在当前目录中。"; \
	    echo "或者Makefile中CNAME 存在值错误，请予以修正。";\
	    exit 1; \
	else \
	    echo "文件$(CFILE) 存在，继续执行..."; \
	fi


check_file:
	@if [ ! -f $(TEXFILE) ];then \
	    echo "错误: 文件$(TEXFILE)不存在！"; \
	    echo "请确保该文件在当前目录中。"; \
	    echo "或者Makefile中TEXFILE 存在值错误，请予以修正。";\
	    exit 1; \
	else \
	    echo "文件$(TEXFILE) 存在，继续执行..."; \
	fi

# 检查 xelatex 是否存在
check_tex:
	@if ! type $(TEXP) > /dev/null 2>&1; then \
	    echo "错误: $(TEXP) 不可用，请确保它已安装并在您的 PATH 中."; \
	    exit 1; \
	fi
#检查函数
check_all: check_file check_tex

# 编译输出pdf文件: make, make all
pdf: check_all
	@echo "编译 PDF 文件开始..."
	$(TEX) $(TEXFILE)	
	@echo "编译完成，请用 PDF 阅读器打开相关文件"
	@echo "请输入 make help 来获取帮助"

# 在tex文件中插入汇总奖状附件信息
# 新到旧顺序排列(2025年排在2021年前面)
collect: check_collect check_collectout
	scripts/getAttachs.sh $(CFILE) $(COUTF)
	@echo "汇总内容生成完毕，可在当前目录下查看<附件汇总清单.csv>或编译以查看效果..."
	@echo "可进行下一步编译: make"

# 旧到新顺序排列(2021年排在2025年前面)
rcollect: check_collect check_collectout
	scripts/getAttachs.sh $(CFILE) $(COUTF) -r
	@echo "汇总内容生成完毕，可在当前目录下查看<附件汇总清单.csv>或编译以查看效果..."
	@echo "可进行下一步编译: make"

# 文中出现的排列
ncollect: check_collect check_collectout
	scripts/getAttachs.sh $(CFILE) $(COUTF) -n
	@echo "汇总内容生成完毕，可在当前目录下查看<附件汇总清单.csv>或编译以查看效果..."
	@echo "可进行下一步编译: make"

# 将自动插入内容删除
# 或者自己在 tex文件中删除
restore: check_collect check_collectout
	scripts/getAttachs.sh $(CFILE) $(COUTF) -d
	@echo "插入汇总内容已经从<.tex>文件中移除"

tur:
	$(TEX) $(TURFILE) 
	@echo "说明书编译完成"

# 清理编译生成的文件
clean:
	rm -f *.csv *.aux *.log *.txss2 *.out *.synctex.gz 2>/dev/null
	@echo "编译产物清理完毕"

# 帮助信息
help:
	@echo "使用说明:"
	@echo "  make             编译 PDF 文件"
	@echo "  make all         等同于 'make'"
	@echo "  make collect     插入汇总奖状附件信息，按新到旧顺序排列"
	@echo "  make rcollect    插入汇总奖状附件信息，按旧到新顺序排列"
	@echo "  make ncollect    按附件文中出现顺序排列"
	@echo "  make restore     删除自动插入的内容(可手动在 tex 文件中删除)"
	@echo "  make clean       清理编译生成的临时文件"
	@echo "  make tur         生成说明书"
	@echo "  make product     重命名 PDF 文件，更改为适合投递的名字"
	@echo "  make help        显示此帮助信息"
