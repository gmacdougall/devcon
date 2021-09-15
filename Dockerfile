FROM archlinux

RUN pacman -S -y --noconfirm --needed \
  bat \
  base-devel \
  bat \
  deno \
  docker \
  docker-compose \
  efm-langserver \
  fd \
  fish \
  fisher \
  fzf \
  git \
  git-delta \
  github-cli \
  go \
  httpie \
  jq \
  libyaml \
  man-db \
  mariadb-libs \
  neovim \
  net-tools \
  openbsd-netcat \
  openssh \
  postgresql-libs \
  ripgrep \
  shared-mime-info \
  starship \
  tmux \
  unzip \
  yarn

RUN ln -s /usr/bin/nvim /usr/local/bin/vim
RUN ln -s /usr/bin/nvim /usr/local/bin/vi

RUN useradd -m gmacdougall
RUN echo "Defaults:gmacdougall !requiretty" > /etc/sudoers.d/gmacdougall
RUN echo "gmacdougall ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/gmacdougall

USER gmacdougall

RUN git clone --depth 1 https://aur.archlinux.org/yay.git /tmp/yay
WORKDIR /tmp/yay
RUN makepkg -si --noconfirm
RUN rm -rf /tmp/yay

RUN git clone --recurse-submodules -j8 "https://github.com/gmacdougall/dotfiles.git" /home/gmacdougall/.dotfiles
RUN /home/gmacdougall/.dotfiles/install
RUN sudo chsh -s /usr/bin/fish gmacdougall

RUN yay -S --noprovides --noconfirm --answerclean=N --answerdiff=N \
  chruby \
  chruby-fish \
  ruby-install

ARG RUBY_VERSION="2.7.4"
RUN ruby-install ruby-$RUBY_VERSION
RUN rm -rf /home/gmacdougall/src
RUN fish -c 'fisher update'
RUN fish -c "chruby ruby; ruby -e 'puts \"ruby-$RUBY_VERSION\"' > /home/gmacdougall/.ruby-version"
RUN fish -c "chruby ruby; gem install bundler rubocop-daemon solargraph"

ARG NODE_VERSION="14.17.6"
RUN fish -c "nvm install $NODE_VERSION"
RUN fish -c "set --universal nvm_default_version $NODE_VERSION"
RUN fish -c "nvm use $NODE_VERSION && npm install -g dprint eslint_d prettier_d_slim typescript-language-server http-server"

RUN yay -S --noprovides --noconfirm --answerclean=N --answerdiff=N nvim-packer-git
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

WORKDIR /tmp
ADD ts_install.sh /tmp
RUN /tmp/ts_install.sh

WORKDIR /home/gmacdougall
