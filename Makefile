OUTPUT_MEMBER_KEYRINGS := \
	output/keyrings/blisslabs-keyring.pgp \
	# EOL

OUTPUT_KEYRINGS := \
	$(OUTPUT_MEMBER_KEYRINGS) \
	# EOL

OUTPUT_COMPAT_KEYRINGS := \
	$(patsubst %.pgp,%.gpg,$(OUTPUT_KEYRINGS)) \
	# EOL

OUTPUT_FILES := \
	$(OUTPUT_KEYRINGS) \
	$(OUTPUT_COMPAT_KEYRINGS) \
	output/sha512sums.txt \
	# EOL

all: $(OUTPUT_FILES)

output/keyrings/blisslabs-keyring.pgp:
	cat keyring/0x* > $@

# FIXME: To have a smooth transition, for now we hardlink the keyrings, so
# that we do not entangle the Debian infrastructure updates that would need
# to cope with the symlinks, from the Debian packaging updates for the
# archive. Once the infra is updated we can switch from the first command
# to the second commented command.
output/keyrings/blisslabs-keyring.gpg: output/keyrings/blisslabs-keyring.pgp
	ln -f $< $@
#	ln -sf $(<F) $@

output/sha512sums.txt: $(OUTPUT_KEYRINGS)
	cd output; sha512sum keyrings/* > sha512sums.txt

output/README: README
	cp README output/

output/changelog: debian/changelog
	cp debian/changelog output/

output/openpgpkey: $(OUTPUT_MEMBER_KEYRINGS)
	cd output && ../scripts/update-keyrings build-wkd debian.org keyrings/blisslabs-keyring.pgp

test: all

clean:
	rm -f output/keyrings/*.pgp output/keyrings/*.gpg output/sha512sums.txt output/README output/changelog output/keyrings/*~
	rm -rf gpghome output/openpgpkey
